# frozen_string_literal: true

class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: I18n.t("authentication.alerts.rate_limit_exceeded") }

  def new
  end

  def create
    if user = User.authenticate_by(user_params)
      start_new_session_for user
      redirect_to after_authentication_url, notice: I18n.t("authentication.alerts.signed_in")
    else
      redirect_to new_session_path, alert: I18n.t("authentication.alerts.invalid_credentials")
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, alert: I18n.t("authentication.alerts.signed_out")
  end

  private
    # Encapsulating parameter filtering in a private method improves maintainability.
    # Normally, using `params.expect` would be preferred for stricter parameter validation.
    # However, SecurePassword's `authenticate_by` method internally calls `attributes.to_h.partition`,
    # which requires a hash structure rather than an array.
    #
    # Using `params.expect(:email_address, :password)` would return an array,
    # causing `authenticate_by` to break. Therefore, we use `params.permit` instead.
    def user_params
      params.permit(:email_address, :password)
    end
end
