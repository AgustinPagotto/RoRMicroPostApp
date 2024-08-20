require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test 'login with valid information followed by logout' do
    post login_path, params: { session: { email: @user.email, password: 'password' } }
    assert is_logged_in?
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    # Verifies that the login path anchor is not present
    assert_select 'a[href=?]', login_path, count: 0
    assert_select 'a[href=?]', logout_path
    assert_select 'a[href=?]', user_path(@user)
    delete logout_path
    assert_not is_logged_in?
    assert_response :see_other
    assert_redirected_to root_url
    follow_redirect!
    assert_select 'a[href=?]', login_path
    assert_select 'a[href=?]', logout_path, count: 0
    assert_select 'a[href=?]', user_path(@user), count: 0
  end
  test 'invalid login information' do
    get login_path
    assert_template 'session/new'
    post login_path, params: {
      session: { email: 'user@invalid',
                 password: 'foo' }
    }
    assert_response :unprocessable_entity
    assert_template 'session/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end
  # Exercise
  test 'login with valid email/invalid password' do
    get login_path
    assert_template 'session/new'
    post login_path, params: {
      session: { email: @user.email,
                 password: 'foo' }
    }
    assert_not is_logged_in?
    assert_response :unprocessable_entity
    assert_template 'session/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end
end
