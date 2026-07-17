class User < ApplicationRecord
  # --- Devise Configuration ---
  devise :database_authenticatable, :recoverable, :rememberable, :validatable

  # --- Associations ---
  # Self-referential associations for staff hierarchy
  belongs_to :owner, class_name: "User", foreign_key: "owner_id", optional: true
  has_many :employees, class_name: "User", foreign_key: "owner_id", dependent: :destroy

  # 1. Define base relationships FIRST
  belongs_to :store, optional: true
  has_many :memberships, inverse_of: :user, dependent: :destroy

  # 2. Define "through" relationships SECOND
  has_many :stores, through: :memberships

  # Sales tracking
  has_many :sales, foreign_key: :shop_keeper_id, dependent: :restrict_with_error

  # --- Nested Attributes ---
  accepts_nested_attributes_for :memberships

  # --- Enums & Validations ---
  enum :role, {
    admin: 0,
    shop_keeper: 1,
    inventory_officer: 2
  }

  validates :full_name, presence: true
  validates_associated :stores

  # Ghanaian phone number format validation (+233XXXXXXXXX)
  validates :phone_number,
            format: { with: /\A\+233\d{9}\z/, message: "is invalid (must be +233XXXXXXXXX)" },
            allow_blank: true

  # --- Scopes ---
  scope :active, -> { where(active: true) }

  # --- Callbacks ---
  before_validation :normalize_phone_number

  # --- Logic Methods ---
  def active_for_authentication?
    super && active?
  end

  def inactive_message
    active? ? super : :inactive_user
  end

  def self.new_with_session(params, session)
    super if defined?(super)
    new(params)
  end

  def display_name
    full_name.presence || "Unnamed User"
  end

  private

  # Normalizes local 024/055/etc numbers to the required standard +233 format
  def normalize_phone_number
    return if phone_number.blank?

    # Strip any spaces or accidental characters
    self.phone_number = phone_number.strip

    if phone_number.start_with?("0")
      self.phone_number = "+233#{phone_number[1..-1]}"
    end
  end
end
