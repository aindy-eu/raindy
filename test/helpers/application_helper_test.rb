# frozen_string_literal: true

require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  include TestHelpers::Shared::FlashHelper

  test "flash_class returns correct CSS classes for known flash keys" do
    assert_equal "bg-red-100 text-red-700", flash_class("alert")
    assert_equal "bg-blue-100 text-blue-700", flash_class("notice")
    assert_equal "bg-green-100 text-green-700", flash_class("success")
    assert_equal "bg-amber-100 text-amber-700", flash_class("warning")
    assert_equal "bg-blue-100 text-blue-700", flash_class("unknown")
  end

  test "flash_alert generates correct HTML structure" do
    rendered = render inline: "<%= flash_alert('success', 'Chat created!') %>"
    assert_flash_structure(rendered, key: "success", value: "Chat created!", css: "bg-green-100 text-green-700")
  end

  test "flash_alert handles empty value" do
    rendered = render inline: "<%= flash_alert('notice', '') %>"
    # puts "Rendered HTML: #{rendered}"
    assert_flash_structure(rendered, key: "notice", value: "", css: "bg-blue-100 text-blue-700")
  end
end
