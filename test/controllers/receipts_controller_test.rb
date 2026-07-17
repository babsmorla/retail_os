require "test_helper"

class ReceiptsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
   sale = sales(:one)
   sign_in users(:one)

get shop_keeper_receipt_url(sale)
    assert_response :success
  end
end
