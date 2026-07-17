require "csv"
class Product < ApplicationRecord
  belongs_to :category,
             optional: true
  belongs_to :store
validates :sku, presence: true, uniqueness: { scope: :store_id, message: "has already been taken in this store" }

  has_many :stock_movements,
           dependent: :destroy

  has_many :stock_adjustments,
           dependent: :destroy

  has_many :sale_items,
           dependent: :restrict_with_error

  validates :name,
            presence: true

  validates :unit_price,
            presence: true




  scope :available,
        -> {
          where("quantity_on_hand > 0")
        }

  DEFAULT_LOW_STOCK = 5

  def low_stock_threshold
    self[:low_stock_threshold] || DEFAULT_LOW_STOCK
  end

  def low_stock?
    quantity_on_hand <= low_stock_threshold
  end

  scope :active, -> { where(active: true) }

  def self.to_csv
    attributes = %w[name sku unit_price cost_price quantity_on_hand]

    CSV.generate(headers: true) do |csv|
      csv << attributes # Header row

      all.each do |product|
        csv << attributes.map { |attr| product.send(attr) }
      end
    end
  end
end
