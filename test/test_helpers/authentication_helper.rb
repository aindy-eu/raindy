# frozen_string_literal: true

module TestHelpers
  module AuthenticationHelper
    def login_as(user)
      post session_url, params: { email_address: user.email_address, password: user.password }
    end

    def logout
      delete session_url
    end
  end
end
