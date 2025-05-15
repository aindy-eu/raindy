# frozen_string_literal: true

require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = create(:user)
  end

  test "should get redirected to login if not authenticated" do
    get root_url
    assert_redirected_to new_session_url(locale: I18n.locale)

    assert_equal I18n.t("authentication.alerts.not_authenticated"), flash[:alert]
  end

  test "should get dashboard if authenticated" do
    login_as(@user)

    get root_url
    assert_response :success
  end

  test "should logout and redirect to login" do
    login_as(@user)

    logout
    assert_redirected_to new_session_url(locale: I18n.locale)

    get root_url
    assert_redirected_to new_session_url(locale: I18n.locale)
  end
end
