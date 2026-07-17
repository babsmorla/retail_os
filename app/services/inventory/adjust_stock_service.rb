module Inventory
  class AdjustStockService
    def initialize(product:, quantity:, adjustment_type:, reason:, user:)
      @product = product
      @quantity = quantity.to_i
      @adjustment_type = adjustment_type
      @reason = reason
      @user = user
    end


    def call
      ActiveRecord::Base.transaction do
        adjustment =
          StockAdjustment.create!(
            product: @product,
            quantity: @quantity,
            adjustment_type: @adjustment_type,
            reason: @reason,
            user: @user
          )


        movement_quantity =
          @adjustment_type == "add" ? @quantity : -@quantity


        new_quantity =
          @product.quantity_on_hand + movement_quantity


        if new_quantity < 0
          raise StandardError, "Cannot remove more stock than is available."
        end


        @product.update!(
          quantity_on_hand: new_quantity
        )


        StockMovement.create!(
          product: @product,
          quantity: movement_quantity,
          movement_type: :adjustment,
          reference: adjustment
        )


        if @adjustment_type == "add"

          AccountingEntry.create!(
            amount: @product.cost_price * @quantity,
            entry_type: :restock_cost,
            description: @reason,
            reference: adjustment
          )

        end


        adjustment
      end
    end
  end
end
