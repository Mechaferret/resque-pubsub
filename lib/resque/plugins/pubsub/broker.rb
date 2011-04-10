module Resque
  module Plugins
    module Pubsub
      class Broker

        @queue = :messages
        # Returns a top-level Redis connection so that the broker can distribute messages
        # across namespaces. If none has been created, will
        # create a new one using information from the Resque connection.
        def self.redis
          return @redis if @redis
          client_to_copy = Resque.redis.client
          @redis = Redis.new(:host => client_to_copy.host, :port => client_to_copy.port, :thread_safe => true, :db => client_to_copy.db)
        end

        def self.perform(topic, message)
          subscribers = Exchange.redis.smembers("#{topic}_subscribers")
          subscribers.each do |s|
            sinfo = JSON.parse(s)
            puts "distributing to #{sinfo.inspect}"
            Broker.redis.sadd("#{sinfo['namespace']}:queues", "fanout:#{topic}")
            Broker.redis.rpush("#{sinfo['namespace']}:queue:fanout:#{topic}", {:class=> sinfo["class"], :args=>[message]}.to_json)
          end
        end

      end
    end
  end
end