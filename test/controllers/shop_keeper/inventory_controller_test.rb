require "test_helper"

class ShopKeeper::InventoryControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get shop_keeper_inventory_index_url
    assert_response :success
  end
end
