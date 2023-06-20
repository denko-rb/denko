# -*- encoding: utf-8 -*-
require File.expand_path('../lib/denko/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["vickash, Austinbv"]
  gem.email         = ["mail@vickash.com"]
  gem.description   = %q{GPIO library for Ruby}
  gem.summary       = %q{GPIO library for Ruby}
  gem.homepage      = 'https://github.com/denko-rb/denko'
  gem.files         = `git ls-files`.split($\)

  # Copy full submodule contents into the gem when building.
  # Credit:
  # https://gist.github.com/mattconnolly/5875987#file-gem-with-git-submodules-gemspec
  #
  # get an array of submodule dirs by executing 'pwd' inside each submodule
  gem_dir = File.expand_path(File.dirname(__FILE__)) + "/"
  `git submodule --quiet foreach pwd`.split($\).each do |submodule_path|
    # Fix submodule paths on Windows.    
    if RUBY_PLATFORM.match(/mswin|mingw/i)
      submodule_path = `cygpath -m #{submodule_path}`.strip
    end

    Dir.chdir(submodule_path) do
      submodule_relative_path = submodule_path.sub gem_dir, ""
      # issue git ls-files in submodule's directory and
      # prepend the submodule path to create absolute file paths
      `git ls-files`.split($\).each do |filename|
        gem.files << "#{submodule_relative_path}/#{filename}"
      end
    end
  end

  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "denko"
  gem.require_paths = ["lib"]
  gem.version       = Denko::VERSION
  gem.executables   = ["denko"]

  gem.add_dependency 'rubyserial'
  gem.add_dependency 'bcd'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'minitest'
  gem.add_development_dependency 'simplecov'
end
