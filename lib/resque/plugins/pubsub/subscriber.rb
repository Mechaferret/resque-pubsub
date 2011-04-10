module Resque
  module Plugins
    module Pubsub
      module Subscriber

        def self.included(base)
          base.send(:extend, ClassMethods)
        end

        module ClassMethods
          
          def subscribe(topic, options={})
            @queue = "fanout:#{topic}"
            reader_method = options[:reader_method] || "read_#{topic}_message"
            module_eval <<-"end_eval"
              def self.perform(message)
                self.send("#{reader_method.to_s}", message)
              end
            end_eval
            options[:namespace] = Resque.redis.namespace
            options[:topic] = topic
            options[:class] = self.to_s
            puts "[#{self.to_s}] subscribing with #{options.inspect}"
            Exchange.redis.sadd(:queues, :subscription_requests)
            Exchange.redis.rpush("queue:subscription_requests", { :class => 'Resque::Plugins::Pubsub::Exchange', :args => [options] }.to_json)      
          end
          
        end

      end
    end
  end
end
