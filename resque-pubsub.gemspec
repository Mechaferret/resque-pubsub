Gem::Specification.new do |s|
  s.name              = 'resque-pubsub'
  s.version           = '0.2.0'
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = 'A Resque plugin that provides a lightweight publish/subscribe messaging system.'
  s.homepage          = 'http://github.com/mechaferret/resque-pubsub'
  s.email             = 'mechaferret@gmail.com'
  s.authors           = ['Monica McArthur']
  s.has_rdoc          = false

  s.files             = %w(README.md Rakefile MIT-LICENSE HISTORY.md)
  s.files            += Dir.glob('examples/**/*')
  s.files            += Dir.glob('lib/**/*')
  s.files            += Dir.glob('test/**/*')

  s.add_dependency('resque', '>= 1.9.10')

  s.description       = <<-DESC
    A Resque plugin. Provides a lightweight publish/subscribe messaging system, with message persistence when clients are down.
  DESC
end
