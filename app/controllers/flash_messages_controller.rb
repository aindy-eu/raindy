# frozen_string_literal: true

# Controller for handling flash messages sent via AJAX
# Used by the flash_controller.js Stimulus controller
class FlashMessagesController < ApplicationController
  # Skip authenticity token verification for API-like endpoints
  # skip_forgery_protection only: :create

  # POST /flash_message
  # Receives flash messages from JavaScript and renders them via Turbo Stream
  def create
    flash_data = nil
    status = :ok

    begin
      flash_data = params.require(:flash).permit(:success, :alert, :notice, :warning).to_h
      logger.info("💚 flash_data: #{flash_data}")
    rescue ActionController::ParameterMissing => e
      logger.error("❤️ Missing flash parameter: #{e}")
      flash_data = { alert: I18n.t("alerts.error.internal") }
      status = :bad_request
    end

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "flash_messages",
          partial: "shared/flash_messages",
          locals: { flash: flash_data }
        ), status: status
      end
      format.html { head status }
    end

    # For testing the fallback flash alert
    # head :forbidden
  end
end
