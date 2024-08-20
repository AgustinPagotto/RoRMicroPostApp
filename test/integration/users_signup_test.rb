require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  test 'invalid signup information' do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: {
        user: { name: '',
                email: 'user@invalid',
                password: 'foo',
                password_confirmation: 'bar' }
      }
    end
    assert_response :unprocessable_entity
    assert_template 'users/new'
    # Exercise
    assert_select 'div#error_explanation'
    assert_select 'div.alert'
  end

  test 'valid signup information' do
    get signup_path
    assert_difference 'User.count' do
      post users_path, params: {
        user: { name: 'example user',
                email: 'user@example.com',
                password: 'password',
                password_confirmation: 'password' }
      }
    end
    # this following line allow us to follow the flow to the welcome screen and test the user/show screen (this is necesary due to the redirection)
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
    # Exercise
    assert_not flash.empty?
  end
end
