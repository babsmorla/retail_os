class AccountingEntry < ApplicationRecord

belongs_to :store
 belongs_to :reference,
           polymorphic: true,
           optional: true


  enum :entry_type, {

    sale_revenue: 0,

    refund: 1,

    restock_cost: 2,

    adjustment: 3

  }


  validates :amount,
            presence: true


end