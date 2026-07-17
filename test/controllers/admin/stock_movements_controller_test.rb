require "test_helper"

class Admin::StockMovementsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_stock_movements_index_url
    assert_response :success
  end
end
