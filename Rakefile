#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rspec/core/rake_task'
require 'yard'

AviationData::Application.load_tasks

namespace :db do
  task :rebuild => ['db:drop', 'db:create', 'db:migrate', 'db:seed']
end

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

desc "Check documentation coverage"
task :doc do
  YARD::CLI::Stats.run('--list-undoc')
end
