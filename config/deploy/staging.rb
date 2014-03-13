role :app, %W{#{ENV['STAGING_APP_HOST']}}
role :web, %W{#{ENV['STAGING_APP_HOST']}}
role :db, %W{#{ENV['STAGING_APP_HOST']}}
set :branch, 'master'
set :rails_env, 'staging'

set :default_environment, 'RAILS_ENV' => 'staging'