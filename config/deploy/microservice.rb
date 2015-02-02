role :app, %W(#{ENV['MICROSERVICE_APP_HOST']})
role :web, %W(#{ENV['MICROSERVICE_APP_HOST']})
role :db, %W(#{ENV['MICROSERVICE_APP_HOST']})
set :branch, 'microservice'
set :rails_env, 'microservice'

set :default_environment, 'RAILS_ENV' => 'microservice'

set :application, 'easyreader.cloudspace.com'

set :deploy_to, '/srv/www/easyreader.cloudspace.com'

role :resque_worker, '54.147.248.245'
role :resque_scheduler, '54.147.248.245'

namespace :deploy do
  task :start do
    on roles(:app) do
      execute 'cd /srv/www/easyreader.cloudspace.com/current && '\
      'bundle exec unicorn -E microservice -c /srv/www/easyreader.cloudspace.com/current/config/unicorn/microservice.rb -D'
    end
  end

  task :stop do
    on roles(:app) do
      execute 'kill -QUIT $(cat /srv/www/easyreader.cloudspace.com/unicorn.pid)'
    end
  end

  task :restart do
    invoke 'unicorn:legacy_restart'
  end
end
