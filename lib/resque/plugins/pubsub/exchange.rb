require 'resque'
module Resque
  module Plugins
    #
    # pubsub exchange manager
    #
    module Pubsub
      class Exchange
        @@pubsub_namespace = nil
        # Returns the current Redis connection. If none has been created, will
        # create a new one using information from the Resque connection and our config.
        def self.redis
          return @redis if @redis
          client_to_copy = Resque.redis.client
          redis_new = Redis.new(:host => client_to_copy.host, :port => client_to_copy.port,
            :thread_safe => true, :db => client_to_copy.db)
          puts "making a redis in exchange, namespace will be #{@@pubsub_namespace}"
          @redis = Redis::Namespace.new(@@pubsub_namespace || "resque:pubsub", :redis => redis_new)
        end
        
        @queue = :subscription_requests
        
        def self.perform(subscription_info)
          puts "handling a subscription on the exchange"
          puts "requested subscription is #{subscription_info.inspect}"
          puts "namespace is #{Exchange.redis.namespace}"
          redis = Exchange.redis
          redis.sadd("#{subscription_info["topic"]}_subscribers", {:class=>subscription_info["class"], :namespace=>subscription_info["namespace"]}.to_json)
        end
        
        def self.pubsub_namespace
          @@pubsub_namespace
        end
        
        def self.pubsub_namespace=(n)
          @@pubsub_namespace = n
          @redis.client.disconnect
          @redis = nil
        end
      end
    end
  end
end
