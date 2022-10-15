# frozen_string_literal: true

require 'stringio'
require 'test_helper'
require 'rainbow'
require 'json'
require 'aws-sdk-cloudwatchlogs'

class Aws::App::LoggerTest < Test::Unit::TestCase
  puts 'Test log message: ' + @@test_message =
      '¡Sierra! 🌟 🐭 🌱 🦄 SUCCESS'

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

  test 'pretty-printed object representation not included by default' do
    $logger = Aws::App::Logger.new(output = StringIO.new)
    $logger.debug @@test_message, {id:'10102001', total:'1295', subtotal:'...'}
    assert(
      output.string.include?(@@test_message) &&
      ! Rainbow.uncolor(output.string).include?(':id => "10102001"')
    )
  end

  test 'the pretty option enables the pretty-printed version' do
    $logger = Aws::App::Logger.new(output = StringIO.new,
      pretty:true)
    $logger.debug @@test_message, {id:'10102001', total:'1295', subtotal:'...'}
    assert(
      output.string.include?(@@test_message) &&
      output.string.include?(':id => "10102001"')
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

  test 'log to CloudWatch using the name of a log group' do
    assert Aws::App::Logger.
      new('aws-app-logger-test').
      debug(@@test_message, {id:'10102001', total:'1295', subtotal:'...'})
  end

  # Implicit log group creation.
  test 'creates log group when one does not exist' do
    log_group_name_that_does_not_exist =
      'aws-app-logger-test-' +
      (0...8).map { (65 + rand(26)).chr }.join
    Aws::App::Logger.new log_group_name_that_does_not_exist
    remove_log_group log_group_name_that_does_not_exist
  end

  test 'finds a log group when one does exist' do
    log_group_name_that_does_not_exist =
      'aws-app-logger-test-' +
      (0...8).map { (65 + rand(26)).chr }.join
    Aws::App::Logger.new log_group_name_that_does_not_exist
    Aws::App::Logger.new log_group_name_that_does_not_exist
    remove_log_group log_group_name_that_does_not_exist
  end

  def remove_log_group(name)
    cloudwatch = Aws::CloudWatchLogs::Client.new
    cloudwatch.delete_log_group(
      log_group_name: name
    )
  end

end
