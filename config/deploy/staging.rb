## Generated with 'brightbox' on 2011-05-11 16:48:20 +0100
gem 'brightbox', '>=2.3.8'
require 'brightbox/recipes'

set :application, "mypolygon-geo"
set :domain, "unepwcmc-005.vm.brightbox.net"
role :app, :web, :db, "unepwcmc-005.vm.brightbox.net", :primary => true

set :user , "rails"
set(:deploy_to) { File.join("", "home", user, application) }

set :scm, :git
set :repository, "git@github.com:unepwcmc/Voluntary-REDD--database.git"
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
