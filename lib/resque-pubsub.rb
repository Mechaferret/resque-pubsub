require 'resque'
Dir.glob(File.expand_path('resque/plugins/pubsub/*', File.dirname(__FILE__))).each { |filename| require filename }