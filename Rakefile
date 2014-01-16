#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

AviationData::Application.load_tasks

namespace :db do
  task :rebuild => ['db:drop', 'db:create', 'db:migrate', 'db:seed']
end

unless Rails.env == "production"
  require 'rspec/core/rake_task'
  require 'yard'

  task :default => :spec

  spec_task = Rake::Task['spec']
  spec_task.clear_prerequisites
  spec_task.enhance %w(db:test:prepare db:seed)

  desc "Check documentation coverage"
  task :doc do
    YARD::CLI::Stats.run('--list-undoc')
  end
end
