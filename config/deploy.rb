# config valid only for Capistrano 3.1
lock '3.2.1'

# the repository url is set in config/environment_variables.rb
set :repo_url, ENV['REPOSITORY_URL']

set :stages, %w(staging production microservice)
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

# --- RESQUE SETTINGS ----

# We're using rails in our tasks so this is necessary
set :resque_environment_task, true

# Set the resque workers (hash of queue: numworkers)
set :workers, 'supervisor' => 1,
              'reaper' => 1,
              'feed' => 12

namespace :resque do
  # Enables at exit hooks after resque jobs, this lets tempfiles get cleaned up
  set :default_env,  'RUN_AT_EXIT_HOOKS' => true
end

# ---- END RESQUE SETTINGS ----

# --- SLACK SETTINGS ----

set :slack_subdomain, 'cloudspace'
set :slack_token, '4NokbEVx2VUlXgnEOTGEstAs'

git_user = `git config user.name`.strip

set :slack_channel, 'cs-easy-reader'
set :slack_username, 'Capistrano'
set :slack_emoji, ':capistrano:'
set :slack_user, 'Capistrano'
set :slack_text, lambda {
  "#{fetch(:stage).capitalize} - Branch #{fetch(:current_revision, fetch(:branch))} of " \
  "#{fetch(:application)} deployed by #{git_user} "
}

set :slack_deploy_starting_text, lambda {
  "#{fetch(:stage).capitalize} - #{git_user} started deploy with branch #{fetch(:branch)} for #{fetch(:application)}"
}

# --- END SLACK SETTINGS ----

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

after 'deploy', 'bundler:install'

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