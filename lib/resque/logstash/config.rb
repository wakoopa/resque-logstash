module Resque::Plugin
  module Logstash
    class Config
      attr_accessor :transport, :disabled, :tags

      def initialize
        @transport = Transport::Redis.new('localhost', 6379)
        @disabled = false
        @tags = []
      end

      def disabled?
        disabled
      end
    end
  end
end
