require "test_helper"

class Admin::StockMovementsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
      sign_in users(:one)
    product = products(:one)


get admin_product_stock_movements_url(product)
    assert_response :success
  end
end
