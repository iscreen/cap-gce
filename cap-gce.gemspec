# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cap-gce/version'

Gem::Specification.new do |spec|
  spec.name          = 'cap-gce'
  spec.version       = CapGCE::VERSION
  spec.authors       = ['Dean Lin']
  spec.email         = ['iscreen@gmail.com']

  spec.summary       = %q(Cap-GCE is used to generate Capistrano namespaces and tasks from Google Compute Engine instance metadatas, dynamically building the list of servers to be deployed to.)
  spec.description   = %q(Cap-GCE is used to generate Capistrano namespaces and tasks from Google Compute Engine instance metadatas, dynamically building the list of servers to be deployed to.)
  spec.homepage      = 'https://github.com/iscreen/cap-gce'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = 'https://github.com/iscreen/cap-gce'
  # else
  #   raise 'RubyGems 2.0 or newer is required to protect against ' \
  #     'public gem pushes.'
  # end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'google-api-client', '~> 0.50'
  spec.add_dependency 'capistrano', '>= 3.0'
  spec.add_dependency 'terminal-table'
  spec.add_dependency 'colorize'

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '>= 12.3.3'
end
