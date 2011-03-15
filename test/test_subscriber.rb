class TestSubscriber
  require 'resque-pubsub'
  
  subscribe 'test_topic'
  
  @@last_message = nil
  
  def self.read_test_topic_message(message)
    puts "got test topic message: #{message.inspect}"
    @@last_message = message
  end
  
  def self.last_message
    @@last_message
  end
  
end