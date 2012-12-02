class TestCustomSubscriber
  include Resque::Plugins::Pubsub::Subscriber

  subscribe 'test_custom_topic', :reader_method => :simple

  class << self

    def simple(message)
      @last_message = message
    end

    def last_message
      @last_message
    end

  end

end