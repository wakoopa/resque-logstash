require 'spec_helper'

describe Resque::Logstash do
  class JobLike
    include Resque::Logstash
  end

  let(:job) { JobLike.new }

  describe '#around_perform_logstash_measure' do
    it 'calls logstash_push_time with the duration' do
      expect(job).to receive(:logstash_push_duration).with(be_within(0.01).of(0.3))

      job.around_perform_logstash_measure { sleep 0.3 }
    end
  end

  describe '#logstash_create_event' do
    let(:event) { job.logstash_create_event 0.3 }

    it 'puts classname as the job field' do
      expect(event.fields['job']).to eq('JobLike')
    end

    it 'puts duration in the field' do
      expect(event.fields['duration']).to eq(0.3)
    end

    it 'provides a nice message' do
      expect(event.message).to eq("Job JobLike finished in 0.3s")
    end
  end
end
