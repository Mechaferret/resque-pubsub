require 'resque/plugins/pubsub/exchange'
module Resque
  module Plugins
    #
    # pubsub subscriber
    #
    module Pubsub
      module Subscriber
        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods
          def subscribe(topic, options={})
            @queue = "fanout:#{topic}"
            reader_method = options[:reader_method] || "read_#{topic}_message"
            module_eval <<-"end_eval"
              def self.perform(message)
                self.send("#{reader_method}", message)
              end
            end_eval
            options[:namespace] = Resque.redis.namespace
            options[:topic] = topic
            options[:class] = self.to_s
            puts "Subscriber subscribing with #{options.inspect}"
            Exchange.redis.sadd(:queues, :subscription_requests)
            Exchange.redis.rpush("queue:subscription_requests", {:class=>'Resque::Plugins::Pubsub::Exchange', :args=>[options]}.to_json)      
          end

        end
      end
    end
  end
end
