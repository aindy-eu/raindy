# frozen_string_literal: true

# config/initializers/constants.rb
module Constants
  MIN_PWD_LENGTH = 6
  MAX_PWD_LENGTH = 72
  MIN_NAME_LENGTH = 1
  MAX_CHAT_NAME_LENGTH = 75

  # Characters forbidden in strict validation rules
  # Note: If you add new forbidden characters here (especially "-", "[", "]"),
  # ensure that both STRICT_REGEX and STRICT_HTML_PATTERN generation is still safe.
  FORBIDDEN_CHARACTERS = %w[" ' $ % # @ * = / \\].freeze
  ALERT_DEFAULT_DELAY = 8000
  ALERT_TEST_DELAY = 500
end
