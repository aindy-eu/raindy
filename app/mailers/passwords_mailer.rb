# frozen_string_literal: true

class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    mail subject: I18n.t("authentication.emails.password.reset.subject"), to: user.email_address
  end
end
