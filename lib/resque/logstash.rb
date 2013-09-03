require "resque"
require "logstash/event"

require "resque/logstash/version"
require 'resque/logstash/transport/redis'

module Resque
  module Logstash
    class << self
      attr_accessor :transport
    end

    def around_perform_logstash_measure(*)
      started_at = Time.now
      yield
    ensure
      logstash_push_duration Time.now - started_at
    end

    def logstash_push_duration(duration)
      Resque::Logstash.transport.push logstash_create_event(duration)
    end

    def logstash_create_event(duration)
      LogStash::Event.new "@message" => "Job #{self.class} finished in #{duration}s",
        "@fields" => {
          "job" => self.class.to_s,
          "duration" => duration
        }
    end
  end
end
