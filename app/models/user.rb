# frozen_string_literal: true

class User < ApplicationRecord
  # Includes
  include UuidConcern

  # Constants
  EMAIL_VALIDATION_REGEX = /\A(?:[a-z0-9!#$%&'*+\/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+\/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z]{2,63}|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\z/i

  # Attribute Macros
  # attr_accessor ...

  # Normalizers
  normalizes :email_address, with: ->(e) { e.strip.downcase }

  # Associations
  has_secure_password
  has_many :chats, dependent: :destroy
  has_many :sessions, dependent: :destroy

  # Enums
  # enum ...

  # Callbacks
  # before_validation ...

  # Validations
  validates :email_address, presence: true, uniqueness: true, format: { with: EMAIL_VALIDATION_REGEX, message: I18n.t("errors.messages.invalid_email") }

  # Delegations
  # delegate ...

  # Scopes
  # scope ...

  # Class Methods
  # def self.method_name ...

  # Instance Methods
  # def method_name ...
end
