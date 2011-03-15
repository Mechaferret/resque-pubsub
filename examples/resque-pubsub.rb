# Put this file in config/initializers to control how resque and resque-pubsub are run

rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../../../..'
rails_env = ENV['RAILS_ENV'] || 'development'

REDIS_CONFIG = YAML.load_file(rails_root + '/config/redis.yml')[rails_env]
Resque.redis = REDIS_CONFIG["host"] + ':' + REDIS_CONFIG["port"].to_s

namespace = ENV['RESQUE_NAMESPACE'] || 'mynamespace' # Edit this to use a different namespace for Resque in the app
Resque.redis.namespace = namespace
require "#{rails_root}/vendor/plugins/resque-pubsub/lib/resque/plugins/pubsub/exchange.rb"
Resque::Plugins::Pubsub::Exchange.pubsub_namespace = 'resque:pubsub' # Edit this to use a different namespace for pubsub
