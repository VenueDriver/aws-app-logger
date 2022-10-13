# frozen_string_literal: true

require 'logger'
require 'json'
require_relative "logger/version"

module Aws
  module App
    class Error < StandardError; end

    class StructuredLogger < ::Logger

      def add(severity, *args, &block)
        case args.count
        when 1
          super(severity, args.first, &block)
        when 2
          super(severity, nil,
            args.shift +
            "\n  " + args.shift.to_json,
          &block)
        end
      end

      %w{debug info warn error fatal unknown}.each do |level|
        define_method level.to_sym do |*args, &block|
          add(eval("::Logger::#{level.upcase}"), *args, &block)
        end
      end

    end
  end
end