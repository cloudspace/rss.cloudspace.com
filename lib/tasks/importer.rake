namespace :importer do
  desc 'start the importer'
  task :start, [:workers] => [:environment] do |t, args|
    puts "ARGS: #{args.inspect}"

    # default to 10 workers
    workers = args[:workers] || 10

    # catch the kill signal from any newly started importer and die gracefully
    Signal.trap('TERM') do 
      killthread = Thread.new do
        Service::Supervisor.instance.stop_workers
        Service::Supervisor.logger.info "SIGTERM detected, bailing out!"
      end

      killthread.join
      exit!
    end

    kill_importers

    Service::Supervisor.logger.info "Starting importer!"

    supervisor = Service::Supervisor.instance

    # clean up and start new workers
    supervisor.stop_workers
    supervisor.cleanup
    puts "WORKERS: #{workers.inspect}"
    supervisor.start_workers(workers.to_i)
  end

  desc 'kill any running status_updater tasks'
  task :stop => :environment do
    kill_importers
  end

  # gets the pids of all importer rake tasks except this one
  def kill_importers
    ps = `ps -ef | grep 'importer:start'`
    rake_processes = ps.split("\n").select { |process| process !~ /grep/ }
    rake_pids = rake_processes.map { |process| process.split[1] }
    pids = rake_pids.reject { |pid| Process.pid.to_s == pid }.map(&:to_i)
    pids.each { |pid| Process.kill('TERM', pid) }
  end
end