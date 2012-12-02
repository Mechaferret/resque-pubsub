module Resque
  module Plugins
    module Pubsub
      class Exchange

        @queue = :subscription_requests

        class << self

          def redis
            return @redis if @redis
            client_to_copy = Resque.redis.client
            redis_new = Redis.new(:host => client_to_copy.host, :port => client_to_copy.port, :thread_safe => true, :db => client_to_copy.db)
            @redis = Redis::Namespace.new(@pubsub_namespace || 'resque:pubsub', :redis => redis_new)
          end

          def perform(subscription_info)
            Exchange.redis.sadd("#{subscription_info["topic"]}_subscribers", { :class => subscription_info['class'], :namespace => subscription_info['namespace'] }.to_json)
          end

          def pubsub_namespace
            @pubsub_namespace
          end

          def pubsub_namespace=(namespace)
            @pubsub_namespace = namespace
            @redis.client.disconnect if @redis
            @redis = nil
          end

        end

      end
    end
  end
end
