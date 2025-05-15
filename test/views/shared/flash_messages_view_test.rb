# frozen_string_literal: true

require "test_helper"

class FlashMessagesViewTest < ActionView::TestCase
  include TestHelpers::Shared::FlashHelper

  test "renders multiple flash messages with correct IDs" do
    flash = { "notice" => "Chat created!", "alert" => "Error occurred" }
    rendered = render partial: "shared/flash_messages", locals: { flash: flash }

    assert_match(/id="flash_messages"/, rendered)
    assert_flash_structure(rendered, key: "notice", value: "Chat created!", css: "bg-blue-100 text-blue-700")
    assert_flash_structure(rendered, key: "alert", value: "Error occurred", css: "bg-red-100 text-red-700")
  end

  test "renders dialog_flash_messages when dialog_message is true" do
    flash = { "success" => "Chat updated!" }
    rendered = render partial: "shared/flash_messages", locals: { flash: flash, dialog_message: true }

    assert_match(/id="dialog_flash_messages"/, rendered)
    assert_flash_structure(rendered, key: "success", value: "Chat updated!", css: "bg-green-100 text-green-700")
  end

  test "renders no flash messages when flash is empty" do
    rendered = render partial: "shared/flash_messages", locals: { flash: {} }
    assert_no_match(/<div class="alert/, rendered)
  end
end
