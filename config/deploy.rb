require 'capistrano/ext/multistage'
set :default_stage, 'staging'

set :scm, :git
set :repository, "git@github.com:unepwcmc/mypolygon-geo.git"
set :branch, "master"
set :scm_username, "unepwcmc-read"


