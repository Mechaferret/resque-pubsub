require 'resque/plugins/pubsub/subscriber'
require 'resque/plugins/pubsub/publisher'
require 'resque/plugins/pubsub/broker'
self.send(:include, Resque::Plugins::Pubsub::Subscriber)
self.send(:include, Resque::Plugins::Pubsub::Publisher)

