# frozen_string_literal: true

module Aws
  module App
    class Logger < ::Logger
      class Formatter < ::Logger::Formatter
        Format = "[%s #%d%s] %s: %s\n"
        DatetimeFormat = "%Y-%m-%dT%H:%M:%S.%6N"
        def call(severity, time, progname, msg)
          # The AWS Lambda request ID, when available, is available in an
          # undocumented global variable that's provided by the AWS Ruby
          # runtime: https://github.com/aws/aws-lambda-ruby-runtime-interface-client/blob/main/lib/aws_lambda_ric/lambda_log_formatter.rb#L12
          progname = progname ||
            begin
              $_global_aws_request_id
            rescue
              nil
            end
          Format % [
            format_datetime(time).strip,
            Process.pid,
            progname ? " #{progname}" : '',
            severity,
            msg2str(msg)
          ]
        end
      end
    end
  end
end
