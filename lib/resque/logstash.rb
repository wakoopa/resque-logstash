require "resque"
require "logstash/event"
require 'forwardable'

require "resque/logstash/version"
require 'resque/logstash/transport/redis'
require 'resque/logstash/config'


module Resque::Plugins
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
    rescue Exception => e
      raise
    ensure
      logstash_push_duration Time.now - started_at, args, e
    end

    def logstash_push_duration(duration, args, exception)
      return if Logstash.config.disabled?
      Logstash.config.transport.push logstash_create_event(duration, args, exception)
    end

    def logstash_create_event(duration, args, exception)
      if exception.nil?
        params = {'status' => 'success'}
        verb = 'finished'
      else
        params = {
          'status' => 'failure',
          'exception' => "#{exception.class}: #{exception.message}"
        }
        verb = 'failed'
      end

      params = params.merge "message" => "Job #{self.name} #{verb} in #{duration}s",
        "job" => self.name,
        "duration" => duration,
        "job_arguments" => args.map { |a| a.to_s },
        "tags" => Logstash.config.tags

      LogStash::Event.new params
    end
  end
end
