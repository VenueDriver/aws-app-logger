# frozen_string_literal: true

require 'logger'
require_relative "logger/version"

module Aws
  module App
    class Error < StandardError; end

    class Logger

      def initialize(io:nil)
        @logger = ::Logger.new(io ||= STDOUT)
      end

      # For handling 'debug', 'warn', etc
      def method_missing(name, *args, &block)
        @logger.send(name, *args, &block)
      end

    end
  end
end