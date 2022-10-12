# frozen_string_literal: true

require 'logger'
require 'json'
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

      def add(severity, *args, &block)
        case args.count
        when 1
          @logger.add(severity, args.first, &block)
        when 2
          @logger.add(severity, nil,
            args.shift +
            "\n  " + args.shift.to_json,
          &block)
        end
      end

      def debug(*args, &block)
        add(::Logger::DEBUG, *args, &block)
      end

    end
  end
end