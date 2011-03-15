class TestSubscriberCustom
  require 'resque-pubsub'
  
  subscribe 'test_custom_topic', :reader_method => 'simple'
  
  @@last_message = nil
  
  def self.simple(message)
    puts "in simple, got test custom topic message: #{message.inspect}"
    @@last_message = message
  end
  
  def self.last_message
    @@last_message
  end
  
end