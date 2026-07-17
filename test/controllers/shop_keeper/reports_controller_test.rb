require "test_helper"
class ShopKeeper::ReportsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    sign_in users(:one)
    ShopKeeper::ReportsController.any_instance.stubs(:current_store).returns(stores(:one))
    get shop_keeper_reports_url
    assert_response :success
  end
end
