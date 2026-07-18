# test/system/smoke_test.rb
require "application_system_test_case"

class SmokeTest < ApplicationSystemTestCase
  test "sign in page loads" do
    visit new_user_session_path
    assert_selector "form"
  end
end
