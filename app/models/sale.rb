class Sale < ApplicationRecord
  # 1. ASSOCIATIONS
  belongs_to :shop_keeper, class_name: "User"
  belongs_to :store
  belongs_to :staff, class_name: 'User', optional: true
  
  has_many :sale_items, dependent: :destroy
  has_many :products, through: :sale_items
  
  has_one :receipt, dependent: :destroy
  has_one :accounting_entry, as: :reference, dependent: :destroy

  accepts_nested_attributes_for :sale_items, allow_destroy: true

  # 2. Callbacks
  # Changed this to before_validation so uniqueness checks can run cleanly!
  before_validation :generate_receipt_number, on: :create
  before_save :calculate_total
  before_update :prevent_confirmed_sale_changes

  # 3. SCOPES
  scope :today, -> {
    where(created_at: Time.current.beginning_of_day..Time.current.end_of_day)
  }

  default_scope { where(store_id: ::Current.store_id) }

  scope :recent, -> {
    order(created_at: :desc)
  }

  # 4. ENUMS
  enum :status, {
    pending: 0,
    confirmed: 1,
    voided: 2
  }

  enum :payment_method, {
    cash: 0,
    card: 1,
    mobile_money: 2
  }

  # 5. VALIDATIONS
  validate :must_have_items
  validates :receipt_number, uniqueness: true, allow_blank: true

  # 6. CSV EXPORT
  def self.to_csv
    require 'csv'
    
    attributes = %w[receipt_number created_at shop_keeper_email payment_method subtotal tax_total discount_total grand_total]

    CSV.generate(headers: true) do |csv|
      csv << attributes.map(&:humanize)

      all.each do |sale|
        csv << [
          sale.receipt_number,
          sale.created_at.strftime("%d %b %Y %H:%M"),
          sale.shop_keeper&.email || "Unknown System User",
          sale.payment_method.to_s.humanize,
          sale.subtotal,
          sale.tax_total,
          sale.discount_total,
          sale.grand_total
        ]
      end
    end
  end

  def must_have_items
    if sale_items.empty? || sale_items.all?(&:marked_for_destruction?)
      errors.add(:base, "Sale must contain at least one item")
    end  
  end

  # UPDATED: Generates high-entropy receipt numbers (e.g., RS-20260717070022-K2P8)
  def generate_receipt_number
  return if receipt_number.present?

  # 1. Grab the store name or fall back to "RS" if it's missing
  store_name = store&.name

  if store_name.present?
    # Split the name by spaces (e.g., "Accra Mall" -> ["Accra", "Mall"])
    words = store_name.strip.split(/\s+/)
    
    if words.size > 1
      # Take the first letter of each word (e.g., "Accra Mall" -> "AM")
      prefix = words.map { |word| word[0] }.join.upcase
    else
      # For single words, take the first 3 letters (e.g., "Aroma" -> "ARO")
      prefix = store_name[0..2].upcase
    end
  else
    prefix = "RS"
  end

  # 2. Append the date and a secure 4-digit random suffix
  # Generates formats like: AM-20260717-A9F3
  timestamp = Time.current.strftime('%Y%m%d') # Shorter, cleaner date format
  random_suffix = SecureRandom.alphanumeric(4).upcase

  self.receipt_number = "#{prefix}-#{timestamp}-#{random_suffix}"
end

  def prevent_confirmed_sale_changes
    if status_was == "confirmed"
      errors.add(:base, "Confirmed sales cannot be edited")
      throw(:abort)
    end
  end

  def calculate_total
    self.grand_total = sale_items.sum do |item|
      item.quantity.to_i * item.unit_price_at_sale.to_f
    end
  end
end