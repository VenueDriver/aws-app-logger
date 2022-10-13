# frozen_string_literal: true

require 'logger'
require 'json'
require 'awesome_print'
require_relative "logger/version"

module Aws
  module App
    class Error < StandardError; end

    class StructuredLogger < ::Logger

      # Option to suppress pretty-printing strucutured data.
      attr_accessor :nopretty

      def initialize(
        # The original Logger interface:
        logdev, shift_age = 0, shift_size = 1048576, level: DEBUG,
        progname: nil, formatter: nil, datetime_format: nil,
        binmode: false, shift_period_suffix: '%Y%m%d',
        # Added for this class:
        nopretty:false
      )

        # Handle the new things.
        self.nopretty = nopretty

        super(
          # The original interface (without the added things) copied and pasted:
          logdev, shift_age = 0, shift_size = 1048576, level: DEBUG,
          progname: nil, formatter: nil, datetime_format: nil,
          binmode: false, shift_period_suffix: '%Y%m%d',
        )
      end

      def add(severity, *args, &block)
        case args.count
        when 1
          # This is the old style of logging, where there is one message.
          super(severity, args.first, &block)
        else
          # This is when you pass an object in addition to your message.
          message =
            # The first thing you pass becomes the first line of your message,
            args.shift +
            # and the second thing that you pass becomes a line of JSON data.
            "\n  " + (remainder = args.shift).to_json
          # Unless you suppress it, you'll also see your data pretty-printed.
          unless self.nopretty
            message += ("\n#{remainder.class}\n#{remainder.ai}").gsub(/^/,'  ')
          end
          super(severity, nil, message, &block)
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