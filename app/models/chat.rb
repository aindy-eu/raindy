# frozen_string_literal: true

class Chat < ApplicationRecord
  include UuidConcern
  include StrictValidationConcern
  include SanitizationConcern

  # Constants

  # Attribute Macros
  # attr_accessor ...

  # Normalizers
  normalizes :name, with: ->(n) { n.strip }

  # Associations
  belongs_to :user

  # Enums
  # enum ...

  # Callbacks
  # Concern - Sanitize input before validation
  sanitize_columns :name, tags: [], attributes: [], strip: true

  # Validations
  validates :name,
    presence: true,
    length: {
      minimum: Constants::MIN_NAME_LENGTH,
      maximum: Constants::MAX_CHAT_NAME_LENGTH,
      allow_blank: true
    }

  # Enforces that chat names do not contain forbidden characters
  # (defined in Constants::FORBIDDEN_CHARACTERS), ensuring safety and consistency.
  strict_validate :name, with: STRICT_REGEX

  # Delegations
  # delegate ...

  # Scopes
  default_scope { order(created_at: :desc) }
  scope :asc, -> { reorder(created_at: :asc) }

  # Class Methods
  # def self.method_name ...

  # Instance Methods
  # def method_name ...
end
