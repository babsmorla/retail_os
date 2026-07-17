module Accounting
  class CreateSaleEntryService
    # Update to accept store as the second argument
    def initialize(sale, store)
      @sale = sale
      @store = store
    end

    def call
      AccountingEntry.create!(
        reference: @sale,
        store: @store, # Assuming your AccountingEntry belongs to a store
        entry_type: :sale_revenue,
        amount: @sale.grand_total,
        description: "Sale #{@sale.receipt_number}"
      )
    end
  end
end
