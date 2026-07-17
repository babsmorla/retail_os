require "test_helper"

class ShopKeeper::InventoryControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
  sign_in users(:one)

  get shop_keeper_inventory_index_url

  assert_response :success
end
end
