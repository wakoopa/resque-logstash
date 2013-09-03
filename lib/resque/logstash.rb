require "resque"
require "logstash/event"

require "resque/logstash/version"
require 'resque/logstash/transport/redis'

module Resque
  module Logstash
    class << self
      attr_accessor :transport, :tags
    end

    def around_perform_logstash_measure(*args)
      started_at = Time.now
      yield
    ensure
      logstash_push_duration Time.now - started_at, args
    end

    def logstash_push_duration(duration, args)
      Resque::Logstash.transport.push logstash_create_event(duration, args)
    end

    def logstash_create_event(duration, args)
      LogStash::Event.new "@message" => "Job #{self.name} finished in #{duration}s",
        "@fields" => {
          "job" => self.name,
          "duration" => duration,
          "job_arguments" => args.map { |a| a.to_s }
        },
        "@tags" => Resque::Logstash.tags
    end
  end
end
