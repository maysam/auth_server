require 'test_helper'

class UserControllerTest < ActionDispatch::IntegrationTest
  test "user should be able to signup and login" do
    post sign_up_path, params: {password: 'blank'}
    assert_response :unprocessable_entity

    post sign_up_path, params: {email: 'john@gmail.com', password: 'blank'}
    assert_response :created

    post sign_up_path, params: {email: 'john@gmail.com', password: 'blank'}
    assert_response :unprocessable_entity

    post user_token_path, params: {auth: {email: 'john@gmail.com', password: 'blank'}}
    assert_response :created

    post user_token_path, params: {auth: {email: 'joe@gmail.com', password: 'blank'}}
    assert_response :not_found

    post user_token_path, params: {auth: {email: 'john@gmail.com', password: 'blanket'}}
    assert_response :not_found
  end
end
