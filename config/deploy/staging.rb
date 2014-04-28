role :app, %W{#{ENV['STAGING_APP_HOST']}}
role :web, %W{#{ENV['STAGING_APP_HOST']}}
role :db, %W{#{ENV['STAGING_APP_HOST']}}
set :branch, 'asset_sync'
set :rails_env, 'staging'

set :default_environment, 'RAILS_ENV' => 'staging'

set :application, 'staging.rss.cloudspace.com'

set :deploy_to, '/srv/www/staging.rss.cloudspace.com'

namespace :deploy do
  task :start do
    on roles(:app) do
      execute 'cd /srv/www/staging.rss.cloudspace.com/current && '\
      'bundle exec unicorn -E staging -c /etc/unicorn/staging.rss.cloudspace.com.rb -D'
    end
  end

  task :stop do
    on roles(:app) do
      execute 'kill -QUIT $(cat /var/run/staging.rss.cloudspace.com_unicorn.pid)'
    end
  end

  task :restart do
    on roles(:app) do
      execute 'kill -USR2 $(cat /var/run/staging.rss.cloudspace.com_unicorn.pid)'
    end
  end
end
