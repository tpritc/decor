ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

module RecordErrorsAssertions
  def assert_record_errors(count: nil)
    assert_select "#record-errors" do
      if count
        assert_select "[data-error-count=?]", count.to_s
      end
      assert_select "[data-error-message]", minimum: 1
    end
  end

  def assert_no_record_errors
    assert_select "#record-errors", count: 0
  end
end

class ActionDispatch::IntegrationTest
  include RecordErrorsAssertions
end
