set :default_stage, 'staging'
require 'capistrano/ext/multistage'
## Generated with 'brightbox' on 2012-05-08 09:53:55 +0100
gem 'brightbox', '>=2.3.9'
require 'brightbox/recipes'
require 'brightbox/passenger'

require 'rvm/capistrano'
set :rvm_ruby_string, '1.9.3'

set :generate_webserver_config, false

ssh_options[:forward_agent] = true

set :application,"mypolygon-geo"

set(:deploy_to) { File.join("", "home", user, application) }



set :default_stage, 'staging'

set :scm, :git
set :repository, "git@github.com:unepwcmc/mypolygon-geo.git"
set :branch, "master"
set :scm_username, "unepwcmc-read"
set :deploy_via, :remote_cache

default_run_options[:pty] = true




