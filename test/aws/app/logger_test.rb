# frozen_string_literal: true

require 'stringio'
require 'test_helper'
require 'rainbow'
require 'json'

class Aws::App::LoggerTest < Test::Unit::TestCase
  puts 'Test log message: ' + @@test_message =
    Rainbow(' ¡Sierra! ').bright.magenta.bg(:white) +
    ' 🌟 🐭 🌱 🦄 ' +
    Rainbow(' SUCCESS ').green.bg(:black)

  test 'VERSION' do
    assert do
      Aws::App::Logger.const_defined?(:VERSION)
    end
  end

  # Existing functionality from Logger, passed through.

  test 'output includes message' do
    $logger = Aws::App::Logger.new(output = StringIO.new)
    $logger.debug @@test_message
    assert output.string.include? @@test_message
  end

  test 'output includes severity' do
    $logger = Aws::App::Logger.new(output = StringIO.new)
    $logger.debug @@test_message
    assert output.string =~ /debug/i
  end

  test 'output includes appropriate severity log lines' do
    $logger = Aws::App::Logger.new(output = StringIO.new)
    $logger.level = :info
    $logger.info @@test_message
    $logger.debug @@test_message
    assert output.string =~ /info/i and output.string !~ /debug/i
  end

  test 'existing formatter interface still works' do
    $logger = Aws::App::Logger.new(output = StringIO.new)
    $logger.formatter = proc {|severity, time, p, msg| "TEST#{severity}: #{msg}\n" }
    $logger.debug @@test_message
    assert output.string =~ /TESTDEBUG/i
  end

  # New functionality for AWS CloudWatch

  test 'logging an object as JSON with debug' do
    $logger = Aws::App::Logger.new(output = StringIO.new)
    $logger.debug @@test_message, {id:'10102001', total:'1295', subtotal:'...'}
    assert(
      output.string.include?(@@test_message) &&
      JSON.parse(output.string.split("\n")[1])['id'].eql?('10102001')
    )
  end

  test 'logging an object includes pretty-printed version' do
    $logger = Aws::App::Logger.new(output = StringIO.new)
    $logger.debug @@test_message, {id:'10102001', total:'1295', subtotal:'...'}
    assert(
      output.string.include?(@@test_message) &&
      Rainbow.uncolor(output.string).include?(':id => "10102001"')
    )
  end

  test 'the nopretty option disables the pretty-printed version' do
    $logger = Aws::App::Logger.new(output = StringIO.new,
      nopretty:true)
    $logger.debug @@test_message, {id:'10102001', total:'1295', subtotal:'...'}
    assert(
      output.string.include?(@@test_message) &&
      ! Rainbow.uncolor(output.string).include?(':id => "10102001"')
    )
  end

  # AWS CloudWatch provides the timestamp and that's better anyway.
  test 'the default formatter does not include the timestamp' do
    $logger = Aws::App::Logger.new(output = StringIO.new)
    $logger.debug @@test_message
    assert(
      !( output.string =~ /\d\d\d\d\-\d\d\-\d\d/ )
    )
  end

end
