# frozen_string_literal: true

module TestHelpers
  module Chats
    module ChatHelper
      def html_create_chat(name:)
        post chats_url, params: { chat: { name: name } }
      end

      def html_update_chat(chat, name:)
        patch chat_url(chat), params: { chat: { name: name } }
      end

      def turbo_create_chat(name:)
        post chats_url(format: :turbo_stream), params: { chat: { name: name } }
      end

      def turbo_update_chat(chat, name:)
        patch chat_url(chat, format: :turbo_stream), params: { chat: { name: name } }
      end

      def assert_chat_name_errors
        assert_select "#chat_name_error div:nth-of-type(1)", text: I18n.t("activerecord.errors.models.chat.attributes.name.blank")
        assert_select "#chat_name_error div:nth-of-type(2)", text: I18n.t("activerecord.errors.models.chat.attributes.name.invalid_characters")
      end
    end
  end
end
