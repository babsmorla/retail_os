module Receipts
  class GenerateReceiptService
    # Ensure this matches exactly
    def initialize(sale, store)
      @sale = sale
      @store = store
    end

    def call
      @store.receipts.create!(
        sale: @sale,
        printed_at: Time.current
      )
    end
  end
end
