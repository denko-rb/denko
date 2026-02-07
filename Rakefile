#!/usr/bin/env ruby
require "bundler/gem_tasks"
require 'rake/testtask'
require 'yard'

task :default => [:test]
Rake::TestTask.new do |t|
  t.libs << "lib"
  t.libs << "test"
  t.warning = false
  t.test_files = FileList['test/**/*_test.rb']
end

# YARD documentation task
YARD::Rake::YardocTask.new(:yard) do |t|
  t.files   = ['lib/**/*.rb']
  t.options = ['--output-dir', 'doc', '--readme', 'README.md', '--markup', 'markdown']
end

desc 'Generate YARD documentation'
task :doc => :yard
