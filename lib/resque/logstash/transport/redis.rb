module Resque::Plugins
  module Logstash
    module Transport
      class Redis
        def initialize(host, port, key = 'logstash')
          @host = host
          @port = port
          @key = key
        end

        attr_accessor :host, :port, :key

        def redis
          @redis ||= ::Redis.new(host: host, port: port)
        end

        def push(value)
          redis.rpush @key, value.to_json
        end
      end
    end
  end
end
