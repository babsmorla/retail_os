require "test_helper"

class ShopKeeper::ReportsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get shop_keeper_reports_index_url
    assert_response :success
  end
end
