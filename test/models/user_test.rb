require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: "Example User", email: "example@email.com",
                    password: "foobarfoo", password_confirmation: "foobarfoo")
  end

  test "should be valid" do
    assert @user.valid?
  end


  test "email should be present" do
    @user.email = " "
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "A" * 51
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "E" * 244 + "@example.com"
    assert_not @user.valid?
  end

  test "email should be valid email address" do
    valid_email = %w[user@example.com USER@foo.COM A_US_eR@foo.bar.org first.last@foo.jp alice+bob@bab.cn]
    valid_email.each do |email|
      @user.email = email
      assert @user.valid?, "Email address #{email.inspect} should be valid"
    end
  end

  test "email should reject invalid email address" do
    invalid_email = %w[user@example,com USER_at_foo.COM A_US_eR#foo.bar.org first.last.foo.jp alice+bob@bab_baz.cn example.ex@example.10]
    invalid_email.each do |email|
      @user.email = email
      assert_not @user.valid?, "#{email.inspect} should be invalid"
    end
  end

  test "email address should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "password should have a minimum length" do
    @user.email = @user.password_confirmation = "E" * 8
    assert_not @user.valid?
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end

end
