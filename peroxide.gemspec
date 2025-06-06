# frozen_string_literal: true

require_relative 'lib/peroxide/version'

Gem::Specification.new do |spec|
  spec.name = 'peroxide'
  spec.version = Peroxide::VERSION
  spec.authors = ['Adam Sumner']
  spec.email = ['adam@gojilabs.com']

  spec.summary = 'Validate request and response bodies in Rails applications'
  spec.description = 'This Ruby gem ensures that the request and response data passed to it conform to the output specified in each sanitizer.'
  spec.homepage = 'https://github.com/gojilabs/peroxide'
  spec.required_ruby_version = '>= 3.3'

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '>= 5.0', '< 8'
  spec.add_dependency 'rack', '>= 2.0', '< 4'

  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'debug'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '>= 1.0'
  spec.add_development_dependency 'ruby-lsp'
  spec.add_development_dependency 'simplecov', '~> 0.22.0'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
