gem 'brightbox', '>=2.3.8'
require 'brightbox/recipes'
#require 'bundler/capistrano'

set :application, "mypolygon-geo"
set :domain, "unepwcmc-004.vm.brightbox.net"
## List of servers
role :app, "unepwcmc-004.vm.brightbox.net"
role :web, "unepwcmc-004.vm.brightbox.net"
role :db, 'unepwcmc-004.vm.brightbox.net', :primary => true

#set :user , "rails"
set(:deploy_to) { File.join("", "home", user, application) }

set :scm, :git
set :repository, "git@github.com:unepwcmc/mypolygon-geo.git"
set :branch, "master"
set :scm_username, "unepwcmc-read"
set :scm_password, "conservation1"

set :scm_verbose, true
default_run_options[:pty] = true

namespace :deploy do
  task :restart, :roles => :app do
    run "mkdir -p #{release_path}/tmp && touch #{release_path}/tmp/restart.txt"
  end
end

set :generate_webserver_config, false
set :skip_db_setup, true
set :skip_rake_tasks, true
