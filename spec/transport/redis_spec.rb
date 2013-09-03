require 'spec_helper'

describe Resque::Logstash::Transport::Redis do
  let(:transport) { Resque::Logstash::Transport::Redis.new('localhost', 6379) }

  describe '#initialize' do
    it 'accepts host, port and the key' do
      transport = Resque::Logstash::Transport::Redis.new('host', 42, 'key')
      expect(transport.host).to eq('host')
      expect(transport.port).to eq(42)
      expect(transport.key).to eq('key')
    end
  end

  describe '#push' do
    it 'calls rpush on redis' do
      expect(transport.redis).to receive(:rpush).with('logstash', '{"a":1}')

      transport.push(a: 1)
    end
  end
end
