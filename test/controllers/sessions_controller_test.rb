# frozen_string_literal: true

# test/controllers/sessions_controller_test.rb
require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
  end

  test "should get new session page" do
    get new_session_path
    assert_response :success
  end

  test "should authenticate with correct credentials" do
    post session_path, params: {
      email_address: @user.email_address,
      password: @user.password
    }
    assert_redirected_to root_path(locale: I18n.locale)
    assert_equal I18n.t("authentication.alerts.signed_in"), flash[:notice]
  end

  test "should not authenticate with incorrect email" do
    post session_path, params: {
      email_address: "wrong@example.com",
      password: @user.password
    }
    assert_redirected_to new_session_path(locale: I18n.locale)
    assert_equal I18n.t("authentication.alerts.invalid_credentials"), flash[:alert]
  end

  test "should not authenticate with incorrect password" do
    post session_path, params: {
      email_address: @user.email_address,
      password: "wrongpassword"
    }
    assert_redirected_to new_session_path(locale: I18n.locale)
    assert_equal I18n.t("authentication.alerts.invalid_credentials"), flash[:alert]
  end

  test "should destroy session and redirect to new session page" do
    post session_path, params: { email_address: @user.email_address, password: @user.password }
    original_session_id = session[:session_id]

    delete session_path

    # Assert that the session ID is different (done with 'reset_session')
    refute_equal original_session_id, session[:session_id]

    # For later ;) - If we are storing user-specific data
    # we want to check that it's cleared:
    assert_nil session[:user_id]

    assert_redirected_to new_session_path(locale: I18n.locale)
    assert_equal I18n.t("authentication.alerts.signed_out"), flash[:alert]
  end
end
