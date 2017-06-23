#!/usr/bin/env rake

require 'chef'
require 'cookstyle'
require 'foodcritic'
require 'knife_cookbook_doc/rake_task'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'stove/rake_task'

task default: [:doc, :rubocop, :foodcritic]

desc 'Run all tasks'
task all: [:doc, :rubocop, :foodcritic, :spec]

desc 'Build README'
task doc: [:knife_cookbook_doc]

desc 'Generate README.md from _README.md.erb'
KnifeCookbookDoc::RakeTask.new do |t|
  t.options = { template_file: 'doc/README.md.erb' }
end

FoodCritic::Rake::LintTask.new do |t|
  t.options = { fail_tags: ['all'] }
end

# begin
#   require 'kitchen/rake_tasks'
#   Kitchen::RakeTasks.new
# rescue LoadError
#   puts '>>>>> Kitchen gem not loaded, omitting tasks.' unless ENV['CI']
# end

RSpec::Core::RakeTask.new

RuboCop::RakeTask.new do |task|
  task.options << '--display-cop-names'
  task.formatters = ['progress']
end

Stove::RakeTask.new
