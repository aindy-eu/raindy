# frozen_string_literal: true

class Session < ApplicationRecord
  # Includes
  include UuidConcern

  # Associations
  belongs_to :user
end
