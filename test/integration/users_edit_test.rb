require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test 'unsuccessful edit' do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user),
          params: { user: { name: '', email: 'foo@invalid.com', password: 'foo', password_confirmation: 'fee' } }
    assert_template 'users/edit'
  end

  test 'successful edit' do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user),
          params: { user: { name: 'Robert', email: 'robert@gmail.com', password: '',
                            password_confirmation: '' } }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal 'Robert', @user.name
    assert_equal 'robert@gmail.com', @user.email
  end
end
