require 'test_helper'

class IntegrationTests < Minitest::Test
  def test_get_login_path
    state = '/redirected_from/123'
    expected_redirect = "https://canvasurl.com/login/oauth2/auth?" \
                        "client_id=123&" \
                        "response_type=code&" \
                        "state=#{state}&" \
                        "redirect_uri=http://example.org/canvas-auth-token"

    get app.login_path, {:state => state}

    assert_equal 302, last_response.status
    assert_equal expected_redirect, last_response.headers['Location']
  end

  def test_get_logout_path
    access_token = 456
    RestClient::Request.expects(:execute).with({
      :method => :delete,
      :url    => "https://canvasurl.com/login/oauth2/token",
      :payload => {
        :headers => {
          :authorization => "Bearer #{access_token}"
        }
      }
    }).returns('')

    get app.logout_path, {}, {'rack.session' => {'access_token' => access_token }}
    assert_equal 302, last_response.status
    assert !session.has_key?('user_id') && !session.has_key?('access_token')

    follow_redirect!
    assert last_response.ok?
  end

  def test_get_token_path
    state = '/redirected_from/path'

    app.set :oauth_callback, lambda {|x|}
    app.expects(:oauth_callback)

    user_id = 123
    access_token = 456
    api_response = {'access_token' => access_token, 'user' => { 'id' => user_id }}.to_json
    RestClient.stubs(:post).returns(api_response)

    get app.token_path, {'state' => state}
    assert_equal 302, last_response.status
    assert_equal user_id, session['user_id']
    assert_equal access_token, session['access_token']

    follow_redirect!
    assert_equal state, last_request.path
  end

  def test_unauthenticated_request
    unauthorized_redirect = '/not_authorized'
    app.set :exempt_paths, ['/login/oauth2/auth']
    RestClient.stubs(:post).returns("{}")

    get '/', {}, {'rack.session' => {}}
    assert_equal 302, last_response.status

    follow_redirect!
    assert_equal 302, last_response.status
    assert_equal app.settings.login_path, last_request.path

    follow_redirect!
    assert_equal '/login/oauth2/auth', last_request.path
  end

  def test_unauthorized_request
    unauthorized_redirect = '/not_authorized'
    app.set :unauthorized_redirect, unauthorized_redirect

    app.expects(:authorized).returns(false)

    get '/', {}, {'rack.session' => {'user_id' => 123}}
    assert_equal 302, last_response.status

    follow_redirect!
    assert_equal last_request.path, unauthorized_redirect
  end

  def test_authorized_request
    app.expects(:authorized).returns(true)
    get '/', {}, {'rack.session' => {'user_id' => 123}}
    assert last_response.ok?
  end
end