# frozen_string_literal: true

require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Raindy
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = "Berlin"
    # config.eager_load_paths << Rails.root.join("extras")

    # Set string as the default primary key type to use it as UUID
    # with uuid_concern for all models
    config.generators do |g|
      g.orm :active_record, primary_key_type: :string
    end

    # remove the form field error div
    # "<div class=\"field_with_error\">#{html_tag}</div>".html_safe
    config.action_view.field_error_proc = Proc.new { |html_tag, instance|
      html_tag.html_safe
    }

    config.app_version = "1.0.0"
  end
end
