require 'resque/plugins/pubsub/exchange'
module Resque
  module Plugins
    #
    # pubsub publisher
    #
    module Pubsub
      module Publisher
        def self.included(base)
          base.send(:include, InstanceMethods)
        end

        module InstanceMethods
          def publish(topic, message)
            puts "Publisher publishing #{message} in #{topic}"
            Exchange.redis.sadd(:queues, "messages")
            Exchange.redis.rpush("queue:messages", {:class=>'Resque::Plugins::Pubsub::Broker', :args=>[topic, message]}.to_json)
          end
        end
      end
    end
  end
end