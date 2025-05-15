# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  # Attributes accessible throughout the request.
  attribute :session

  # Delegate the current user from the session if it exists.
  delegate :user, to: :session, allow_nil: true
end
