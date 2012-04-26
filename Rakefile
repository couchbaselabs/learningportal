#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

begin
  require 'ci/reporter/rake/rspec'
rescue LoadError
  STDERR.puts "WARNING: gem ci_reporter not found"
end

LearningPortal::Application.load_tasks
