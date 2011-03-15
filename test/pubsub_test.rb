require File.dirname(__FILE__) + '/test_helper'

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
    assert check_subscription(Resque.redis.smembers("test_topic_subscribers"), "TestSubscriber", "test_pubsub")
    p = TestPublisher.new
    p.publish("test_topic", "Test message")
    # Run Resque for the broker
    Resque.redis.namespace = 'resque:pubsub'
    @worker = Resque::Worker.new(:messages)
    @worker.process
    # Check that the message queue has been populated
    Resque.redis.namespace = 'test_pubsub'
    assert Resque.redis.keys.include?('queue:fanout:test_topic')
    assert Resque.redis.llen('queue:fanout:test_topic')==1
    # Now run the subscriber Resque
    @worker = Resque::Worker.new('fanout:test_topic')
    @worker.process
    assert Resque.redis.llen('fanout:test_topic')==0
    assert TestSubscriber.last_message=='Test message'
  end
  
  def check_subscription(subscribers, klass, namespace)
    subscribers.inject(false) {|result, s|
      sinfo = JSON.parse(s)
      result = result || (sinfo["class"]==klass && sinfo['namespace']==namespace)
    }
  end

end
