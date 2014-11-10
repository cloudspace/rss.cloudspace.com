role :app, %W(#{ENV['PRODUCTION_APP_HOST']})
role :web, %W(#{ENV['PRODUCTION_APP_HOST']})
role :db, %W(#{ENV['PRODUCTION_APP_HOST']})
set :branch, 'resque'
set :rails_env, 'production'

set :default_environment, 'RAILS_ENV' => 'production'

set :application, 'easyreader.cloudspace.com'

set :deploy_to, '/srv/www/easyreader.cloudspace.com'

role :resque_worker, 'easyreader.cloudspace.com'
role :resque_scheduler, 'easyreader.cloudspace.com'

namespace :deploy do
  task :start do
    on roles(:app) do
      execute 'cd /srv/www/easyreader.cloudspace.com/current && '\
      'bundle exec unicorn -E production -c /srv/www/easyreader.cloudspace.com/config/unicorn/production.rb -D'
    end
  end

  task :stop do
    on roles(:app) do
      execute 'kill -QUIT $(cat /srv/www/easyreader.cloudspace.com/unicorn.pid)'
    end
  end

  task :restart do
    on roles(:app) do
      execute 'kill -USR2 $(cat /srv/www/easyreader.cloudspace.com/unicorn.pid)'
    end
  end
end
