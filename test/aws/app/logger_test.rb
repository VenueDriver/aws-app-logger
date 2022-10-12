# frozen_string_literal: true

require "test_helper"

class Aws::App::LoggerTest < Test::Unit::TestCase
  test "VERSION" do
    assert do
      ::Aws::App::Logger.const_defined?(:VERSION)
    end
  end

  test "something useful" do
    assert_equal("expected", "actual")
  end
end
