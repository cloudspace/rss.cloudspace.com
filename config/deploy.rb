# config valid only for Capistrano 3.1
lock '3.2.1'

# the repository url is set in config/environment_variables.rb
set :repo_url, ENV['REPOSITORY_URL']

set :stages, %w(staging production)
set :default_stage, 'staging'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :pretty
set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w(.env)

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
set :linked_dirs, %w(log)

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

set :ssh_options, keys: ['~/.ssh/id_rsa'], forward_agent: true, user: 'ubuntu'

# We're using rails in our tasks so this is necessary
set :resque_environment_task, true

# Set the resque workers (hash of queue: numworkers)
set :workers, 'image' => 1,
              'supervisor' => 1,
              'feeds, feed_items' => 10

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  desc 'Run the seeds file'
  task(:seed) { foreground_rake('db:seed') }
end

ater 'deploy', 'bundler:install'
after 'deploy', 'importer:start'

# runs the specified rake task on the server in the background, without blocking the ssh session
def background_rake(task)
  on roles(:app) do
    execute "cd #{release_path}; ( ( nohup bundle exec rake RAILS_ENV=#{fetch(:rails_env)} #{task} &>/dev/null ) & )"
  end
end

# runs the specified rake task on the server in the foreground, blocking the ssh session
def foreground_rake(task)
  on roles(:app) do
    execute "cd #{release_path} && bundle exec rake RAILS_ENV=#{fetch(:rails_env)} #{task}"
  end
end
