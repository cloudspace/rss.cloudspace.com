# Supervises ApiQueue::Worker objects. Creates, controls, starts, and stops workers as needed
class Service::Supervisor
  attr_accessor :worker_threads, :running

  # a global supervisor singleton
  def self.instance
    @supervisor = new unless @supervisor
  end

  def initialize(error_threshold: 50)
    # a place to store references to all the workers
    @workers = ThreadSafe::Hash.new
    @worker_threads = ThreadSafe::Hash.new
    cleanup
  end

  attr_accessor :archive, :process

  # instantiates and starts workers. don't create more workers than
  # there are database connections, or the extra workers will sit idle
  # waiting for connections. rails seems to reserve 1-2 connections for
  # itself, so set a pool value in database.yml at least 2 higher
  # than the number of workers for best results
  #
  # @return [Array<Thread>] an array of threads, returned upon completion
  def start_workers(num_workers = 5)
    logger.info "Starting #{num_workers} workers"
    @resurrection_thread = Thread.new do
      loop do
        begin
          cleanup_stuck
          report_workers
          sleep 60
        rescue => e
          logger.info e
        end
      end
    end
  end

  def create_workers
    while @workers.count < num_workers.to_i
      thread_index = @workers.keys.count + 1
      @worker_threads[thread_index] = Thread.new do
        worker = create_worker(thread_index)
        worker.start
      end
      sleep 0.2
    end
  end

  # creates a single Service::Worker
  #
  # @param [String] id the name of this worker for purposes of logging
  # @return [ApiQueue::Worker] the worker that was created
  def create_worker(id)
    worker = Service::Worker.new(id: id, supervisor: self)
    @workers[id] = worker
    worker
  end

  def start_workers
    @workers.values.each(&:start)
    @worker_threads.values.each(&:join)
    @resurrection_thread.join
  end

  def report_workers
    logger.info "WORKER THREADS: #{worker_threads.values.map(&:inspect)}"
    logger.info 'WORKER THREADS: Checking for dead threads'
    check_for_dead_workers
    logger.info 'WORKER THREADS: Finished checking for dead threads'
    logger.info "WORKER THREADS: #{worker_threads.values.map(&:inspect)}"
  end

  def check_for_dead_workers
    running_workers = list_running_workers
    if running_workers.length < @workers.count
      (1..@workers.count).each do |worker_id|
        unless running_workers.include?(worker_id)
          logger.info "WORKER THREADS: Killing worker #{worker_id}"
          restart_worker(worker_id)
          logger.info "WORKER THREADS: Restarted worker #{worker_id}"
          sleep 0.2
        end
      end
    end
  end

  def restart_worker(worker_id)
    @worker_threads[worker_id].kill
    @worker_threads[worker_id] = Thread.new do
      worker = create_worker(worker_id)
      worker.start
    end
  end

  # stops all the workers
  def stop_workers
    @resurrection_thread.kill if @resurrection_thread
    @workers.values.each(&:stop)
    true
  end

  # clean up before exiting
  def cleanup
    Feed.processing.update_all(processing: false)
    FeedItem.processing.update_all(processing: false)
  end

  def cleanup_stuck
    FeedItem.cleanup_stuck
    Feed.cleanup_stuck
  end

  def list_running_workers
    worker_logs = `find /srv/www/rss.cloudspace.com/current/log/worker*.log -type f -mmin -5`
    worker_logs = worker_logs.split("\n")
    [].tap do |running_workers|
      worker_logs.each do |worker|
        worker = worker.split('/')[-1]
        running_workers << worker.split('_')[-1].split('.')[0].to_i
      end
    end
  end

  def logger
    self.class.logger
  end

  def self.logger
    return @logger if @logger
    logfile_path = File.join(Rails.root, 'log/supervisor.log')
    # keep up to 5 logfiles, up to 1Mb each
    @logger = Logger.new(logfile_path, 5, 1.megabyte)
    @logger.level = Logger::INFO
    @logger
  end
end
