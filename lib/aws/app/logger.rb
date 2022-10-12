# frozen_string_literal: true

require 'logger'
require_relative "logger/version"

module Aws
  module App
    class Error < StandardError; end

    class Logger

      def initialize(io:nil)
        @logger = ::Logger.new(io ||= STDOUT)
        @logger.level = ::Logger::DEBUG
        @logger.formatter =
          proc {|severity, time, p, msg| "#{severity}: #{msg}\n" }
        byebug
        @logger
      end

      # For handling 'debug', 'warn', etc
      def method_missing(name, *args, &block)
        @logger.send(name, *args, &block)
      end

    end
  end
end