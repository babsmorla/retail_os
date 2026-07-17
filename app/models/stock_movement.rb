class StockMovement < ApplicationRecord
belongs_to :store
belongs_to :store # <--- ADD THIS
  belongs_to :product

  belongs_to :reference,
             polymorphic: true,
             optional: true

  enum :movement_type, {
    purchase: 0,
    sale: 1,
    adjustment: 2,
    return: 3
  }

  validates :movement_type,
            presence: true

  validates :quantity,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than: 0
            }

end