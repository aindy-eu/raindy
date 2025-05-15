# frozen_string_literal: true

# app/models/concerns/sanitization_concern.rb
module SanitizationConcern
  extend ActiveSupport::Concern

  class_methods do
    # Define the columns that need sanitization.
    # This method sanitizes specified columns, optionally removing newlines and tabs,
    # and ensures only the allowed tags and attributes remain.
    #
    # @param columns [Array<Symbol>] The columns to sanitize.
    # @param tags [Array<String>] The allowed HTML tags (default: %w[b i u a]).
    # @param attributes [Array<String>] The allowed HTML attributes (default: %w[href]).
    # @param strip [Boolean] Whether to replace newlines and tabs with spaces (default: false).
    def sanitize_columns(*columns, tags: %w[b i u a], attributes: %w[href], strip: false)
      before_validation do
        columns.each do |column|
          value = self[column]

          # Only process if the value is a string
          next unless value.is_a?(String)

          # Be aware:
          # The sanitization process will convert certain characters into their HTML entity equivalents.
          # For example:
          #   - & becomes &amp;
          #   - < becomes &lt;
          #   - > becomes &gt;
          #   - " becomes &quot;
          #   - ' becomes &#39;
          #   - / becomes &#x2F;
          # If you need to enforce strict validation on these fields (e.g., for names or slugs),
          # ensure you account for this conversion in your regex or validation logic.
          # Consider pairing sanitization with a strict validation concern when necessary.

          # Sanitize the value using Rails' built-in helper
          sanitized_value = ActionController::Base.helpers.sanitize(value, tags: tags, attributes: attributes)

          # Optionally strip newlines and tabs
          self[column] = strip ? sanitized_value.gsub(/[\n\t]/, " ") : sanitized_value
        end
      end
    end
  end
end
