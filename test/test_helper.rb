# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "aws-app-logger"

require "test-unit"
require 'mocha/test_unit'
require 'awesome_print'
require 'byebug'

