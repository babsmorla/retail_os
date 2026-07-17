module Sales
  class ConfirmSaleService
    # Inject the store to make this service reusable outside the controller
    def initialize(sale, store)
      @sale = sale
      @store = store
    end

    def call
  ActiveRecord::Base.transaction do
    validate_stock!
    calculate_totals!
    deduct_inventory!
    confirm_sale!
    # Return the receipt created by the service
    @receipt = generate_receipt
    create_accounting_entry
  end

  @receipt # Return the receipt so the controller can redirect to it
end

    private

    attr_reader :sale, :store

    def validate_stock!
      sale.sale_items.each do |item|
        product = item.product
        if product.quantity_on_hand < item.quantity
          raise "Insufficient stock for #{product.name}"
        end
      end
    end

    def calculate_totals!
      subtotal = sale.sale_items.sum do |item|
        item.quantity.to_d * item.unit_price_at_sale.to_d
      end

      sale.update!(
        subtotal: subtotal,
        discount_total: 0,
        tax_total: 0,
        grand_total: subtotal
      )
    end

    def confirm_sale!
      sale.update!(
        status: :confirmed,
        confirmed_at: Time.current
      )
    end

    def generate_receipt
      Receipts::GenerateReceiptService.new(sale, store).call
    end

    def deduct_inventory!
      sale.sale_items.each do |item|
        product = item.product

        # Lock the product row to prevent race conditions during high-volume sales
        product.lock!

        product.decrement!(:quantity_on_hand, item.quantity)

        # Use the injected store association
        store.stock_movements.create!(
          product: product,
          quantity: item.quantity,
          movement_type: :sale,
          reference: sale
        )
      end
    end

    def create_accounting_entry
      Accounting::CreateSaleEntryService.new(sale, store).call
    end
  end
end
