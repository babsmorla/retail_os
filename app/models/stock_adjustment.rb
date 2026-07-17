class StockAdjustment < ApplicationRecord

  belongs_to :product
  belongs_to :user


  enum :adjustment_type, {
    add: 0,
    remove: 1
  }


  validates :quantity,
            presence: true,
            numericality: { greater_than: 0 }


  validates :reason,
            presence: true


end