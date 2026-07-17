require "test_helper"

class ShopKeeper::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get shop_keeper_dashboard_index_url
    assert_response :success
  end
end
