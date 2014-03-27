module Service
  # Supervises ApiQueue::Worker objects. Creates, controls, starts, and stops workers as needed
  class Supervisor

    def initialize(error_threshold: 50)
      # a place to store references to all the workers
      @workers = ThreadSafe::Array.new
      @worker_threads = ThreadSafe::Array.new
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

      # this allows interrupts to be caught and stop the workers
      # there has to be a better way than this, but i couldn't
      # figure out how
      # TODO: find a better way to handle interrupts gracefully
      Kernel.trap('INT') { stop_workers }

      while @workers.count < num_workers.to_i
        @worker_threads << Thread.new(@workers.count) do |thread_index|
          worker = create_worker(thread_index + 1)
          worker.start
        end
        sleep 0.1
      end

      @workers.each(&:start)
      @worker_threads.each(&:join)
      log 'all workers are now stopped'
    end

    # creates a single Service::Worker
    #
    # @param [String] id the name of this worker for purposes of logging
    # @return [ApiQueue::Worker] the worker that was created
    def create_worker(id)
      worker = Service::Worker.new(id: id, supervisor: self)
      @workers << worker
      worker
    end

    # stops all the workers
    def stop_workers
      @workers.map(&:stop)
      true
    end

    # clean up before exiting
    def cleanup
      Feed.processing.update_all(processing: false)
      FeedItem.processing.update_all(processing: false)
    end

    # logs text into the logfile
    #
    # @param [String] text the text to be logged
    def log(text, id = nil)
      Rails.logger.info text
      File.open("#{Rails.root}/log/supervisor.log", 'a') do |f|
        f.puts(Time.now.strftime('%m/%d/%Y %T') + ' ' + (id ? "(worker #{id})" : '(supervisor)') + ' ' + text)
      end
    end
  end
end
