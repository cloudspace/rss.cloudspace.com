rails_env = ENV['RAILS_ENV'] || 'staging'
worker_processes 1
preload_app true
timeout 30
listen '/srv/www/staging.rss.cloudspace.com/unicorn.sock', :backlog => 2048
pid '/srv/www/staging.rss.cloudspace.com/unicorn.pid'

# Setup logging paths
stderr_path '/srv/www/staging.rss.cloudspace.com/shared/log/unicorn_error.log'
stdout_path '/srv/www/staging.rss.cloudspace.com/shared/log/unicorn_access.log'

working_directory '/srv/www/staging.rss.cloudspace.com/current'

before_exec do |server|
  ENV["BUNDLE_GEMFILE"] = "/srv/www/staging.rss.cloudspace.com/current/Gemfile"
end

before_fork do |server, worker|
  old_pid = '/srv/www/staging.rss.cloudspace.com/unicorn.pid.oldbin'
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection
end
