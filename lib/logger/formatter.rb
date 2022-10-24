# frozen_string_literal: true

module Aws
  module App
    class Logger < ::Logger
      class Formatter < ::Logger::Formatter
        Format = "[%s #%d%s] %s: %s"
        DatetimeFormat = "%Y-%m-%dT%H:%M:%S.%6N"
        def call(severity, time, progname, msg)
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
