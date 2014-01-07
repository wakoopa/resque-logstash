require 'spec_helper'

describe Resque::Plugins::Logstash do
  class JobLike
    extend Resque::Plugins::Logstash
  end

  let(:job) { JobLike }

  before do
    Resque::Plugins::Logstash.transport = double(:push => nil)
  end

  it 'complient with resque plugin policy' do
    expect { Resque::Plugin.lint(Resque::Plugins::Logstash) }.not_to raise_error
  end

  describe '#around_perform_logstash_measure' do
    it 'calls logstash_push_time with the duration' do
      expect(job).to receive(:logstash_push_duration).with(be_within(0.01).of(0.3), [], nil)

      job.around_perform_logstash_measure { sleep 0.3 }
    end

    it 'logs job arguments' do
      expect(job).to receive(:logstash_push_duration).with(kind_of(Numeric), [:test, "blah"], nil)
      expect { job.around_perform_logstash_measure(:test, "blah") {} }.not_to raise_error
    end

    it 'logs errors' do
      expect(job).to receive(:logstash_push_duration).with(anything, anything, kind_of(Exception))
      expect { job.around_perform_logstash_measure { raise "hello" } }.to raise_error
    end
  end

  describe '#logstash_create_event' do
    let(:event) { job.logstash_create_event 0.3, [:arg1, "arg2"], nil }

    it 'puts classname as the job field' do
      expect(event.fields['job']).to eq('JobLike')
    end

    it 'puts duration in the field' do
      expect(event.fields['duration']).to eq(0.3)
    end

    it 'provides a nice message' do
      expect(event['message']).to eq("Job JobLike finished in 0.3s")
    end

    it 'adds tags' do
      Resque::Plugins::Logstash.tags = %w{tag1 tag2}

      expect(event.tags).to include(*%w{tag1 tag2})
    end

    it 'adds job arguments as Strings' do
      expect(event.fields['job_arguments']).to eq(%w{arg1 arg2})
    end

    it 'includes status' do
      expect(event.fields['status']).to eq('success')
    end

    it 'does not include exception key' do
      expect(event.fields).not_to include('exception')
    end

    context 'when called with an exception' do
      let(:event) { job.logstash_create_event 0.3, [:arg1, "arg2"],  ArgumentError.new("test") }

      it 'includes status' do
        expect(event.fields['status']).to eq('failure')
      end

      it 'includes the exception' do
        expect(event.fields['exception']).to eq("ArgumentError: test")
      end

      it 'provides a nice message' do
        expect(event['message']).to eq("Job JobLike failed in 0.3s")
      end
    end
  end

  describe '#logstash_push_duration' do
    it 'calls push on @transport' do
      Resque::Plugins::Logstash.transport = double
      expect(Resque::Plugins::Logstash.transport).to receive(:push)

      job.logstash_push_duration(0.3, [], nil)
    end

    it 'does not push if disabled' do
      Resque::Plugins::Logstash.configure { |c| c.disabled = true }

      expect(Resque::Plugins::Logstash.transport).not_to receive(:push)
      job.logstash_push_duration(0.3, [], nil)

      Resque::Plugins::Logstash.configure { |c| c.disabled = false }
    end
  end

  describe '#configure' do
    it 'yields' do
      yielded = false
      Resque::Plugins::Logstash.configure { yielded = true }
      expect(yielded).to be_true
    end

    it 'yield config object' do
      Resque::Plugins::Logstash.configure do |c|
        %w{transport tags disabled}.each do |method|
          expect(c).to respond_to("#{method}=")
          expect(c).to respond_to("#{method}")
        end
      end
    end
  end
end
