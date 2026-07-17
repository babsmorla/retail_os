class SaleItem < ApplicationRecord
  belongs_to :sale
  belongs_to :product


  validates :quantity,
            numericality: {
              greater_than: 0
            }


  before_validation :set_price_from_product
  before_validation :calculate_total


  private


  def set_price_from_product
    if unit_price_at_sale.blank? && product.present?
      self.unit_price_at_sale = product.unit_price
    end
  end



  def calculate_total
    self.line_total =
      quantity.to_f * unit_price_at_sale.to_f
  end
end
