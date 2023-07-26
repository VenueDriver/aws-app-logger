# frozen_string_literal: true

require 'logger'
require 'json'
require 'oj'; Oj.default_options = {:mode => :compat }
require_relative "logger/version"
require_relative "logger/formatter"

module Aws
  module App
    class Error < StandardError; end

    class Logger < ::Logger

      # Option to suppress pretty-printing strucutured data.
      attr_accessor :pretty

      def initialize(
        # The original Logger interface:
        logdev, shift_age = 0, shift_size = 1048576, level: DEBUG,
        progname: nil, formatter: nil, datetime_format: nil,
        binmode: false, shift_period_suffix: '%Y%m%d',
        # Added for this class:
        pretty:false, log_group:nil
      )

        # Handle the new things.
        self.pretty = pretty

        if logdev.class.eql? String
          log_group = logdev
        end
        if log_group
          @log_group = find_or_create_log_group log_group_name:log_group
          @log_stream = find_or_create_log_stream
          logdev = CloudWatchStringIO.new(
            cloudwatch_client: @cloudwatch,
            log_group:         @log_group,
            log_stream:        @log_stream)
        end

        super(
          # The original interface (without the added things) copied and pasted:
          logdev, shift_age, shift_size, level: level,
          progname: progname, formatter: formatter, datetime_format: datetime_format,
          binmode: binmode, shift_period_suffix: shift_period_suffix,
        )

        @default_formatter = Aws::App::Logger::Formatter.new

        self
      end

      def add(severity, *args, &block)
        # This is the old style of logging, where there is one message and it's
        # an ordinary String, not structured data.
        if args.count.eql?(1) and args.first.class.eql?(String)
          return super(severity, args.first, &block)
        end

        message =
          # Pull out the first argument if it's String, and start the message.
          if args.first.class.eql?(String)
            args.shift + "\n"
          else
            # If it's not a string then leave the arguments in place,
            # and the first argument will be emitted as JSON.
            '' 
          end

        # ...and the second thing that you pass becomes a line of JSON data.
        data_to_log =
          if (remainder = args).count.eql?(1)
            remainder.first
          else
            # The JSON parsing in the Lambda-to-Cloudwatch logs will not
            # recognize a list as valid JSON.  It looks for the first hash
            # that it can find in the log entry.  So, we must pack the list
            # into a hash.
            {records: remainder}
          end
        message += Oj.dump(data_to_log)

        # Unless you suppress it, you'll also see your data pretty-printed.
        if self.pretty
          message += Rainbow.uncolor(
            "\n#{remainder.class}\n#{JSON.pretty_generate(remainder)}")
        end
        super(severity, nil, message, &block)
      end

      %w{debug info warn error fatal unknown}.each do |level|
        define_method level.to_sym do |*args, &block|
          add(eval("::Logger::#{level.upcase}"), *args, &block)
        end
      end

      class NoLogStreamError < StandardError; end
      class NoLogGroupError < StandardError; end

      class CloudWatchStringIO < ::StringIO
        def initialize(cloudwatch_client:, log_group:, log_stream:)
          @cloudwatch     = cloudwatch_client
          @log_group      = log_group
          @log_stream     = log_stream
          @sequence_token = log_stream.upload_sequence_token
        end
        def write(message)
          log_event = {
            log_group_name: @log_group.log_group_name,
            log_stream_name: @log_stream.log_stream_name,
            log_events: [{
              timestamp: (Time.now.utc.to_f.round(3)*1000).to_i,
              message: message
            }]
          }
          if @sequence_token
            log_event[:sequence_token] = @sequence_token
          end
          $stdout.puts "\OUTPUT:#{message}"
          @cloudwatch.put_log_events(log_event).tap do |response|
            @sequence_token = response.next_sequence_token
          end.rejected_log_events_info.nil?
        end
      end

      private

      def find_or_create_log_group(log_group_name:)
        @cloudwatch = Aws::CloudWatchLogs::Client.new
        @log_group_name = log_group_name
        response = @cloudwatch.describe_log_groups({
          log_group_name_prefix: log_group_name,
          limit: 1
        })
        response.log_groups.first.tap do |log_group|
          raise NoLogGroupError if log_group.nil?
        end
      rescue NoLogGroupError
        @cloudwatch.create_log_group(log_group_name: log_group_name)
        retry
      end

      def find_or_create_log_stream
        log_stream_name =
          # One log stream per minute, maximum...
          Time.now.to_s.match( /^([^\:]+\d+)\:(\d+)/ ){
            [$1, '%02d' % ($2.to_i - $2.to_i % 5)] }.join('-').gsub(/\D/,'-')
        response = @cloudwatch.describe_log_streams({
          log_group_name: @log_group_name,
          log_stream_name_prefix: log_stream_name,
          limit: 1
        })
        response.log_streams.first.tap do |log_stream|
          raise NoLogStreamError if log_stream.nil?
          @sequence_token = log_stream.upload_sequence_token
        end
      rescue NoLogStreamError
        @cloudwatch.create_log_stream(
          log_group_name: @log_group_name,
          log_stream_name: log_stream_name
        )
        retry
      end

    end
  end
end