ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "mocha/minitest"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # This line loads your fixtures (users, sales, etc.) and creates the helper methods!
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

# Better practice: Only include Devise helpers where requests actually happen
class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end