dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift dir + '/../lib'
$TESTING = true

require 'rubygems'
require 'test/unit'
require 'resque'
require 'active_support'
require 'active_support/test_case'

require 'resque-pubsub'

# make sure we can run redis
if !system('which redis-server')
  puts '', "** can't find `redis-server` in your path"
  puts "** try running `sudo rake install`"
  abort ''
end

# start our own redis when the tests start,
# kill it when they end
at_exit do
  next if $!

  if defined?(MiniTest)
    exit_code = MiniTest::Unit.new.run(ARGV)
  else
    exit_code = Test::Unit::AutoRunner.run
  end

  pid = `ps -e -o pid,command | grep [r]edis-test`.split(" ")[0]
  puts 'Killing test redis server...'
  `rm -f #{dir}/dump.rdb`
  Process.kill('KILL', pid.to_i)
  exit exit_code
end

puts 'Starting redis for testing at localhost:9736...'
`redis-server #{dir}/redis-test.conf`
Resque.redis = '127.0.0.1:9736'
Resque.redis.namespace = 'test_pubsub'

Dir.glob(File.expand_path(dir + '/fixtures/*')).each { |filename| require filename }