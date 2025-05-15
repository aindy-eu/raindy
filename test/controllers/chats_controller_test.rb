# frozen_string_literal: true

require "test_helper"

class ChatsControllerTest < ActionDispatch::IntegrationTest
  # Should contain high-level or miscellaneous tests for the ChatsController
  # that aren’t covered in more specific files.

  # E.g. we test only the index action here, not the show, new, edit, etc.
  # So if this is not secured - 'Houston, we have a problem'
  test "should get redirected to login if not authenticated" do
    get chats_url
    assert_redirected_to new_session_url(locale: I18n.locale)

    assert_equal I18n.t("authentication.alerts.not_authenticated"), flash[:alert]
  end
end
