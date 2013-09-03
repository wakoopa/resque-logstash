# Resque::Logstash

Logs duration of a resque job in logstash. At the moment only redis
transport is supported.

## Installation

Add this line to your application's Gemfile:

    gem 'resque-logstash'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install resque-logstash

## Usage

```ruby
Resque::Logstash.transport = Resque::Logstash::Transport::Redis.new('localhost', 6379)

class SomeJob
  extend Resque::Logstash

  def self.perform
    # do the heavy lifting here
  end
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
