require File.expand_path('test_helper.rb', File.dirname(__FILE__))

class PubsubTest < Test::Unit::TestCase

  def setup
    $success = $lock_failed = $lock_expired = 0
    Resque.redis.namespace = nil
    Resque.redis.flushall
    Resque.redis.namespace = 'test_pubsub'
  end

  def test_lint
    assert_nothing_raised do
      Resque::Plugin.lint(Resque::Plugins::Pubsub)
    end
  end

  def test_all
    TestSubscriber.subscribe('test_topic')
    # Now process the subscription
    Resque.redis.namespace = 'resque:pubsub'
    Resque::Worker.new(:subscription_requests).process
    # Check that the subscription is in the subscribers list
    assert subscription_exists(Resque.redis.smembers('test_topic_subscribers'), 'TestSubscriber', 'test_pubsub')
  
    p = TestPublisher.new
    p.publish('test_topic', 'Test message')
    # Run Resque for the broker
    Resque.redis.namespace = 'resque:pubsub'
    Resque::Worker.new(:messages).process
    # Check that the message queue has been populated
    Resque.redis.namespace = 'test_pubsub'
    assert Resque.redis.keys.include?('queue:fanout:test_topic')
    assert_equal 1, Resque.redis.llen('queue:fanout:test_topic')
    
    # Now run the subscriber Resque
    Resque::Worker.new('fanout:test_topic').process
    assert_equal 0, Resque.redis.llen('queue:fanout:test_topic')
    assert_equal 'Test message', TestSubscriber.last_message
  end

  def test_configuration_options
    Resque::Plugins::Pubsub::Exchange.pubsub_namespace = 'resque:custom_space'
    TestCustomSubscriber.subscribe('test_custom_topic', :reader_method => :simple)
    # Now process the subscription
    Resque.redis.namespace = 'resque:custom_space'
    Resque::Worker.new(:subscription_requests).process
    # Check that the subscription is in the subscribers list
    assert subscription_exists(Resque.redis.smembers('test_custom_topic_subscribers'), 'TestCustomSubscriber', 'test_pubsub')
    
    TestPublisher.new.publish('test_custom_topic', 'Test custom message')
    # Run Resque for the broker
    Resque.redis.namespace = 'resque:custom_space'
    Resque::Worker.new(:messages).process
    # Check that the message queue has been populated
    Resque.redis.namespace = 'test_pubsub'
    assert Resque.redis.keys.include?('queue:fanout:test_custom_topic')
    assert_equal 1, Resque.redis.llen('queue:fanout:test_custom_topic')
    
    # Now run the subscriber Resque
    Resque::Worker.new('fanout:test_custom_topic').process
    assert_equal 0, Resque.redis.llen('queue:fanout:test_custom_topic')
    assert_equal 'Test custom message', TestCustomSubscriber.last_message
    assert_not_equal 'Test custom message', TestSubscriber.last_message
  end

  private
  
  def subscription_exists(subscribers, klass, namespace)
    subscribers.inject(false) do |result, s|
      sinfo = JSON.parse(s)
      result = result || (sinfo['class'] == klass && sinfo['namespace'] == namespace)
    end
  end

end