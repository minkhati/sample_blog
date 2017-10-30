require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "invalid signup information" do
    get signup_path
    #before_count = User.count
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name:  "",
                                         email: "",
                                         password:              "foo",
                                         password_confirmation: "bar" } }
    end
    #after_count = User.count
    #assert_equal before_count, after_count
    assert_template 'users/new'

    assert_select 'div#error_explanation'
    assert_select 'div.field_with_errors'
    assert_select 'div.alert'
    assert_select 'div.alert-danger'
    assert_select "div", {:text=>"The form contains 5 errors."}
    assert_select "ul li", {:text=>"Name can't be blank"}
    assert_select "ul li", {:text=>"Email can't be blank"}
    assert_select "ul li", {:text=>"Email is invalid"}
    assert_select "ul li", {:text=>"Password confirmation doesn't match Password"}
    assert_select "ul li", {:text=>"Password is too short (minimum is 8 characters)"}
    assert_select "div.field_with_errors", {:count=>8}
    # assert_select 'div#<CSS id for error explanation>'
    # assert_select 'div.<CSS class for field with error>'
    #assert_select 'form[action="/signup"]'
    #assert_select "ul li", { count: 5 }
  end

  test "valid signup information with account activation" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name:  "Example User",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    # Try to log in before activation.
    log_in_as(user)
    assert_not is_logged_in?
    # Invalid activation token
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not is_logged_in?
    # Valid token, wrong email
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?
    # Valid activation token
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end
end
