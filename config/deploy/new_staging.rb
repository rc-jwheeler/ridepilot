set :branch, 'rails-upgrade'
set :rvm_ruby_version, '2.2.0@ridepilot'
set :deploy_to, '/home/deploy/rails/ridepilot'
set :rails_env, 'staging'
set :default_env, { "RAILS_RELATIVE_URL_ROOT" => "/ridepilot" }
server 'apps2.rideconnection.org', roles: [:app, :web, :db], user: 'deploy'
