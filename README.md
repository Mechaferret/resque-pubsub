ResquePubsub
============

A [Resque][rq] plugin. Requires Resque 1.9.10.

A lightweight publish/subscribe messaging system, with message persistence when clients are down, written on top of Redis and Resque.


Usage / Examples
================

A simple class that can publish a message:

  class TestPublisher
    require 'resque-pubsub'
    
    def some_method
      self.publish(topic, message)
    end
  end


A simple class that subscribes to messages on a particular topic:

  class TestSubscriber
    require 'resque-pubsub'
  
    subscribe 'test_topic'
    
    def self.read_test_topic_message(message)
      # Do something with the message
    end
  end


Customize & Extend
==================

The method that the is called when the subscriber is sent a message defaults to read_<topic_name>_message, 
but can be customized with the option :reader_method, e.g.,

    subscribe 'test_topic', :reader_message => :custom_message_method
    
Note that this hasn't been tested yet.


The namespace that pubsub uses in Resque defaults to 'resque:pubsub' but can be configured by setting the constant 
Resque::Plugins::Pubsub::Exchange::PUBSUB_NAMESPACE.

Note that this hasn't been tested yet either.


Install
=======

### As a gem

    $ gem install resque-pubsub

### In a Rails app, as a plugin

    $ rails plugin install git://github.com/mechaferret/resque-pubsub


Running Resque
==============

A sample config file is provided in examples/resque-pubsub.rb. If you put this in config/initializers for a Rails app,
then Resque will default to the app namespace but will take an override on namespace from the environment variable RESQUE_NAMESPACE. Thus

QUEUE=* RESQUE_NAMESPACE="resque:pubsub" rake environment resque:work

will run resque jobs against the default pubsub namespace (i.e., will be the pubsub server)

while 

QUEUE=* rake environment resque:work

will run resque in an app as normal.


Acknowledgements
================

Copyright (c) 2011 Monica McArthur, released under the MIT license.

[rq]: http://github.com/defunkt/resque
