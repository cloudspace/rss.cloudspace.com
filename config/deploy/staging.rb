role :app, %W(#{ENV['STAGING_APP_HOST']})
role :web, %W(#{ENV['STAGING_APP_HOST']})
role :db, %W(#{ENV['STAGING_APP_HOST']})
set :branch, 'resque'
set :rails_env, 'staging'

set :default_environment, 'RAILS_ENV' => 'staging'

set :application, 'staging.easyreader.cloudspace.com'

set :deploy_to, '/srv/www/staging.easyreader.cloudspace.com'

role :resque_worker, 'staging.easyreader.cloudspace.com'
role :resque_scheduler, 'staging.easyreader.cloudspace.com'

namespace :deploy do
  task :start do
    on roles(:app) do
      execute 'cd /srv/www/staging.easyreader.cloudspace.com/current && '\
      'bundle exec unicorn -E staging -c '\
      '/srv/www/staging.easyreader.cloudspace.com/current/config/unicorn/staging.rb -D'
    end
  end

  task :stop do
    on roles(:app) do
      execute 'kill -QUIT $(cat /srv/www/staging.easyreader.cloudspace.com/unicorn.pid)'
    end
  end

  task :restart do
    on roles(:app) do
      execute 'kill -USR2 $(cat /srv/www/staging.easyreader.cloudspace.com/unicorn.pid)'
    end
  end
end
