# frozen_string_literal: true

# app/models/concerns/strict_validation_concern.rb
module StrictValidationConcern
  extend ActiveSupport::Concern
  # StrictValidationConcern:
  #
  # This concern allows models to reuse a strict format validation,
  # ensuring that attributes like `name` do not contain forbidden characters.
  #
  # Forbidden characters are defined globally in `Constants::FORBIDDEN_CHARACTERS`
  # (e.g., " ' $ % # @ * = / \), and apply consistently to both server-side
  # (model validations) and client-side (HTML input patterns).
  #
  # Usage:
  #   strict_validate :name, with: STRICT_REGEX
  #
  # - On the server: It validates using a regular expression.
  # - On the client: You can use `strict_html_pattern` to generate the HTML5 `pattern` attribute.
  #
  # Benefit:
  # - Keeps frontend and backend validations in sync.
  # - Centralizes forbidden character definitions for easy future updates.

  included do
    STRICT_REGEX = /\A(?!.*[#{Regexp.escape(Constants::FORBIDDEN_CHARACTERS.join)}]).+\z/u

    # STRICT_HTML_PATTERN:
    #
    # Builds the HTML5 pattern string from `Constants::FORBIDDEN_CHARACTERS`,
    # escaping `/` and `\` as needed for browser compatibility.
    # Ensures that client-side input validation matches server-side rules (STRICT_REGEX).
    STRICT_HTML_PATTERN = "^[^#{Constants::FORBIDDEN_CHARACTERS.map { |c| c == '\\' ? '\\\\' : c == '/' ? '\\/' : c }.join}]+$"
  end

  class_methods do
    def strict_validate(*attributes, with:)
      attributes.each do |attribute|
        validates attribute, format: { with: with, message: :invalid_characters }
      end
    end

    def strict_html_pattern
      STRICT_HTML_PATTERN
    end

    def strict_forbidden_characters
      Constants::FORBIDDEN_CHARACTERS
    end
  end
end
