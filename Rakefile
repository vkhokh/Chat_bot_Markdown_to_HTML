# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new do |task|
  task.options = ["--force-exclusion"]
  task.patterns = [
    "lib/**/*.rb",
    "spec/**/*.rb",
    "bin/console",
    "demo.rb",
    "test.rb",
    "our_web_gem.gemspec",
    "Rakefile"
  ]
end

task default: %i[spec rubocop]
