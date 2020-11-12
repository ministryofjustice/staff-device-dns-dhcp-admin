# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require "standard/rake"

require_relative "config/application"

Rails.application.load_tasks

task :default do
  Rake::Task["standard:fix"].invoke
  Rake::Task["spec"].invoke
end
