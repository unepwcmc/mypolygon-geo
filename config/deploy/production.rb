set :rails_env, "production"
# Primary domain name of your application. Used in the Apache configs
set :domain, "unepwcmc-013.vm.brightbox.net"
## List of servers
server "unepwcmc-013.vm.brightbox.net", :app, :web, :db, :primary => true

set :application, "mypolygon-geo"
set :server_name, "mypolygon-geo.unepwcmc-013.vm.brightbox.net"
set :sudo_user, "rails"
set :app_port, "80" 


desc "Configure VHost"
task :config_vhost do
vhost_config =<<-EOF
server {
  listen 80;
  
  client_max_body_size 4G;
  server_name #{application}.unepwcmc-013.vm.brightbox.net #{application}.sw01.matx.info;
  keepalive_timeout 5;
  root #{deploy_to}/public;
  passenger_enabled on;
  rails_env production;
  gzip on;
  location ^~ /assets/ {
    expires max;
    add_header Cache-Control public;
  }
  
  if (-f $document_root/system/maintenance.html) {
    return 503;
  }

  error_page 500 502 504 /500.html;
  location = /500.html {
    root #{deploy_to}/public;
  }

  error_page 503 @maintenance;
  location @maintenance {
    rewrite  ^(.*)$  /system/maintenance.html break;
  }
}
EOF
put vhost_config, "/tmp/vhost_config"
sudo "mv /tmp/vhost_config /etc/nginx/sites-available/#{application}"
sudo "ln -s /etc/nginx/sites-available/#{application} /etc/nginx/sites-enabled/#{application}"
end

after "deploy:setup", :config_vhost
 
namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
end


namespace :deploy do
  task :start, :roles => :app do
    run "cd #{release_path} && ./start"
  end
  task :stop, :roles => :app do
    run "cd #{release_path} && ./stop"
  end
  task :restart, :roles => :app do
    deploy.stop
    deploy.start
  end
end
