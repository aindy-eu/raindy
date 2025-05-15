# frozen_string_literal: true

# I18n configuration
# https://guides.rubyonrails.org/i18n.html

# Where the I18n library should search for translation files
# We use "**" so that it searches in all subdirectories
I18n.load_path += Dir[Rails.root.join("config", "locales", "**", "*.{rb,yml}")]

# Permitted locales available for the application
I18n.available_locales = [ :en, :de ]

# Set default locale to something other than :en
I18n.default_locale = :de
