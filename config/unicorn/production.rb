rails_env = ENV['RAILS_ENV'] || 'production'
worker_processes 1
preload_app true
timeout 30
listen '/srv/www/rss.cloudspace.com/unicorn.sock', backlog: 2048
pid '/srv/www/rss.cloudspace.com/unicorn.pid'

# Setup logging paths
stderr_path '/srv/www/rss.cloudspace.com/shared/log/unicorn_error.log'
stdout_path '/srv/www/rss.cloudspace.com/shared/log/unicorn_access.log'

working_directory '/srv/www/rss.cloudspace.com/current'

before_exec do |_server|
  ENV['BUNDLE_GEMFILE'] = '/srv/www/rss.cloudspace.com/current/Gemfile'
end

before_fork do |server, _worker|
  old_pid = '/srv/www/rss.cloudspace.com/unicorn.pid.oldbin'
  if File.exist?(old_pid) && server.pid != old_pid
    begin
      Process.kill('QUIT', File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

after_fork do |_server, _worker|
  ActiveRecord::Base.establish_connection
end
