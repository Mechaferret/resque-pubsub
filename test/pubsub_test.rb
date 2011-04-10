require File.expand_path('test_helper.rb', File.dirname(__FILE__))

class PubsubTest < Test::Unit::TestCase

  def setup
    $success = $lock_failed = $lock_expired = 0
    Resque.redis.flushall
    Resque.redis.namespace = 'test_pubsub'
  end

  def test_lint
    assert_nothing_raised do
      Resque::Plugin.lint(Resque::Plugins::Pubsub)
    end
  end

  def test_all
    # Just loading the "TestSubscriber" class is enough to subscribe
    require 'test_publisher'
    require 'test_subscriber'
    # Now process the subscription
    Resque.redis.namespace = 'resque:pubsub'
    @worker = Resque::Worker.new(:subscription_requests)
    @worker.process
    # Check that the subscription is in the subscribers list
    assert subscription_exists(Resque.redis.smembers("test_topic_subscribers"), "TestSubscriber", "test_pubsub")
    p = TestPublisher.new
    p.publish("test_topic", "Test message")
    # Run Resque for the broker
    Resque.redis.namespace = 'resque:pubsub'
    @worker = Resque::Worker.new(:messages)
    @worker.process
    # Check that the message queue has been populated
    Resque.redis.namespace = 'test_pubsub'
    assert Resque.redis.keys.include?('queue:fanout:test_topic')
    assert Resque.redis.llen('queue:fanout:test_topic') == 1
    # Now run the subscriber Resque
    @worker = Resque::Worker.new('fanout:test_topic')
    @worker.process
    assert Resque.redis.llen('fanout:test_topic') == 0
    assert TestSubscriber.last_message == 'Test message'
  end

  def test_configuration_options
    # Configure the pubsub namespace
    require 'resque-pubsub'
    Resque::Plugins::Pubsub::Exchange.pubsub_namespace = 'resque:custom_space'
    puts "namespace is set to #{Resque::Plugins::Pubsub::Exchange.pubsub_namespace}"
    require 'test_publisher'
    require 'test_subscriber'
    require 'test_subscriber_custom'
    # Now process the subscription
    Resque.redis.namespace = 'resque:custom_space'
    @worker = Resque::Worker.new(:subscription_requests)
    @worker.process
    # Check that the subscription is in the subscribers list
    assert subscription_exists(Resque.redis.smembers("test_custom_topic_subscribers"), "TestSubscriberCustom", "test_pubsub")
    p = TestPublisher.new
    p.publish("test_custom_topic", "Test custom message")
    # Run Resque for the broker
    Resque.redis.namespace = 'resque:custom_space'
    @worker = Resque::Worker.new(:messages)
    @worker.process
    # Check that the message queue has been populated
    Resque.redis.namespace = 'test_pubsub'
    assert Resque.redis.keys.include?('queue:fanout:test_custom_topic')
    assert Resque.redis.llen('queue:fanout:test_custom_topic') == 1
    # Now run the subscriber Resque
    @worker = Resque::Worker.new('fanout:test_custom_topic')
    @worker.process
    assert Resque.redis.llen('fanout:test_custom_topic') == 0
    assert TestSubscriberCustom.last_message == 'Test custom message'
    # Also make sure TestSubscriber DIDN'T get the message
    assert TestSubscriber.last_message != 'Test custom message'
  end

  private
  
  def subscription_exists(subscribers, klass, namespace)
    subscribers.inject(false) do |result, s|
      sinfo = JSON.parse(s)
      result = result || (sinfo["class"] == klass && sinfo['namespace'] == namespace)
    end
  end

end