module Resque::Plugins
  module Logstash
    module Transport
      class Redis
        Undefined = Object.new
        def initialize(host, port = nil, key = 'logstash')
          if host.is_a?(Hash)
            initialize_with_keyword_arguments(host)
          else
            @redis_options = { host: host, port: port }
            @key = key
          end
        end

        def initialize_with_keyword_arguments(key: 'logstash', redis: nil, **redis_options)
          @key = key

          if redis
            @redis = redis
          else
            @redis_options = redis_options
          end
        end

        attr_reader :key

        def redis
          @redis ||= ::Redis.new(@redis_options)
        end

        def host
          @redis_options[:host]
        end

        def port
          @redis_options[:port]
        end

        def push(value)
          redis.rpush @key, value.to_json
        end
      end
    end
  end
end
