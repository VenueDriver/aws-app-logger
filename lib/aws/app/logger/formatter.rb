# frozen_string_literal: true

module Aws
  module App
    class Logger < ::Logger
      class Formatter < ::Logger::Formatter
        Format = "%s: %s\n"
        def call(severity, time, progname, msg)
          Format % [severity, msg2str(msg)]
        end
      end
    end
  end
end
