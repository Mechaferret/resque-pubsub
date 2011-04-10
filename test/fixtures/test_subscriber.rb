class TestSubscriber
  include Resque::Plugins::Pubsub::Subscriber

  subscribe 'test_topic'

  @@last_message = nil

  def self.read_test_topic_message(message)
    puts "[#{self.to_s}] got test topic message: #{message.inspect}"
    @@last_message = message
  end

  def self.last_message
    @@last_message
  end

end