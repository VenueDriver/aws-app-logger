# frozen_string_literal: true

require 'stringio'
require 'test_helper'
require 'rainbow'

class Aws::App::LoggerTest < Test::Unit::TestCase
  puts 'Test log message: ' + @@test_message =
    Rainbow(' ¡Sierra! ').bright.magenta.bg(:white) +
    ' 🌟 🐭 🌱 🦄 ' +
    Rainbow(' SUCCESS ').green.bg(:black)

  test 'VERSION' do
    assert do
      ::Aws::App::Logger.const_defined?(:VERSION)
    end
  end

  test 'output includes message' do
    $logger = ::Aws::App::Logger.new(io: output = StringIO.new)
    $logger.debug @@test_message
    assert output.string.include? @@test_message
  end

  test 'output includes severity' do
    $logger = ::Aws::App::Logger.new(io: output = StringIO.new)
    $logger.debug @@test_message
    assert output.string =~ /debug/i
  end

end
