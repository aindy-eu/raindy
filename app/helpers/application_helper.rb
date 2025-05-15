# frozen_string_literal: true

module ApplicationHelper
  def flash_alert(key, value)
    delay = Rails.env.test? ? Constants::ALERT_TEST_DELAY : Constants::ALERT_DEFAULT_DELAY

    content_tag :div,
      id: "alert-#{key}-#{Time.now.to_i}",
      class: "alert #{flash_class(key)} transition-opacity duration-300",
      role: "alert",
      data: {
        controller: "components--alert",
        components__alert_delay_value: delay
      } do
      concat content_tag(:span, value, data: { components__alert_target: "message" })
      concat button_tag("×",
        type: "button",
        tabindex: "0",
        class: "px-4 py-1.5 bg-transparent hover:bg-white text-2xl rounded-lg cursor-pointer focus:inset-ring-2 focus:inset-ring-violet-500 focus:outline-hidden",
        data: {
          components__alert_target: "closeButton",
          action: "click->components--alert#close"
        },
        aria: { label: "Close" })
    end
  end

  # https://api.rubyonrails.org/classes/ActionDispatch/Flash/FlashHash.html
  def flash_class(key)
    case key
    # Build in flash keys (types)
    when "alert" then "bg-red-100 text-red-700"
    when "notice" then "bg-blue-100 text-blue-700"

    # https://api.rubyonrails.org/classes/ActionController/Flash/ClassMethods.html#method-i-add_flash_types
    when "success" then "bg-green-100 text-green-700"
    when "warning" then "bg-amber-100 text-amber-700"
    else
      "bg-blue-100 text-blue-700"
    end
  end
end
