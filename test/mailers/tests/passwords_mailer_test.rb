# frozen_string_literal: true

# test/mailers/tests/passwords_mailer_test.rb
require "test_helper"

class PasswordsMailerTest < ActionMailer::TestCase
  include Rails.application.routes.url_helpers

  test "reset email overall properties" do
    user = create(:user, email_address: "test@example.com")
    mail = PasswordsMailer.reset(user)

    assert_emails 1 do
      mail.deliver_now
    end

    assert_equal [ "no-reply@example.com" ], mail.from
    assert_equal [ user.email_address ], mail.to
    assert_equal I18n.t("authentication.emails.password.reset.subject"), mail.subject

    # Verifying that the combined email body includes the welcome message.
    combined_body = mail.body.encoded
    assert_match I18n.t("authentication.emails.password.reset.welcome", email: user.email_address), combined_body
  end

  test "reset email has both HTML and text parts with expected content" do
    user = create(:user, email_address: "test@example.com")
    mail = PasswordsMailer.reset(user)

    # Ensure the email is multipart.
    assert mail.multipart?, "Expected email to be multipart with HTML and text parts."

    # Test the text part.
    text_body = mail.text_part.body.encoded
    welcome_text = I18n.t("authentication.emails.password.reset.welcome", email: user.email_address)
    text_body_message = I18n.t("authentication.emails.password.reset.text.body")

    assert_includes text_body, welcome_text, "Text part should include the welcome message."
    assert_includes text_body, text_body_message, "Text part should include the reset instructions message."
    assert_match %r{http://localhost:3044/passwords/.+/edit}, text_body, "Text part should contain a valid password reset URL."

    # Test the HTML part.
    html_body = mail.html_part.body.encoded

    # The HTML part should include the welcome message.
    assert_includes html_body, welcome_text, "HTML part should include the welcome message."

    # The HTML body is translated and interpolated with a link.
    # We can check that it contains the link text and the URL.
    link_text = I18n.t("authentication.emails.password.reset.html.link_text")
    assert_includes html_body, link_text, "HTML part should include the link text."
    assert_match %r{http://localhost:3044/passwords/.+/edit}, html_body, "Text part should contain a valid password reset URL."
  end
end
