require "test_helper"

class DemoControllerTest < ActionDispatch::IntegrationTest
 test "should get index" do
  sign_in users(:one)

  get demo_index_url
  assert_response :success
end
end
