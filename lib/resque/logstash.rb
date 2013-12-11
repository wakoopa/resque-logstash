require "resque"
require "logstash/event"
require 'forwardable'

require "resque/logstash/version"
require 'resque/logstash/transport/redis'
require 'resque/logstash/config'


module Resque
  module Logstash
    class << self
      extend Forwardable

      # support old API
      def_delegators :config, :transport, :transport=, :tags, :tags=

      def configure
        yield config
      end

      def config
        @config ||= Config.new
      end
    end

    def around_perform_logstash_measure(*args)
      started_at = Time.now
      yield
    ensure
      logstash_push_duration Time.now - started_at, args
    end

    def logstash_push_duration(duration, args)
      return if Resque::Logstash.config.disabled?
      Resque::Logstash.config.transport.push logstash_create_event(duration, args)
    end

    def logstash_create_event(duration, args)
      LogStash::Event.new "message" => "Job #{self.name} finished in #{duration}s",
        "job" => self.name,
        "duration" => duration,
        "job_arguments" => args.map { |a| a.to_s },
        "tags" => Resque::Logstash.config.tags
    end
  end
end
