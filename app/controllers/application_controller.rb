# frozen_string_literal: true

class ApplicationController < ActionController::Base
  ## 1. Include Modules (loads first)
  include Authentication

  ## 2. Class-Level Configurations
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  add_flash_types :success, :warning

  ## 3. Before Actions (order matters)
  before_action :set_variant
  before_action :set_app_version
  helper_method :current_user
  around_action :switch_locale

  # https://guides.rubyonrails.org/i18n.html
  def switch_locale(&action)
    locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  def default_url_options
    { locale: I18n.locale }
  end

   private
     def current_user
       # Memoizes the current user to prevent multiple database queries per request.
       # Always use `current_user`, not `@current_user`, because `@current_user`
       # will be nil until `current_user` is called.
       @current_user ||= Current.session&.user
     end

     # https://guides.rubyonrails.org/layouts_and_rendering.html#the-variants-option
     # TODO: Review this implementation
     def set_variant
       user_agent = request.user_agent
       if /Mobile|webOS/.match?(user_agent)
         request.variant = :mobile
       else
         request.variant = :desktop
       end
     end

     def set_app_version
       @app_version = Rails.application.config.app_version
     end
end
