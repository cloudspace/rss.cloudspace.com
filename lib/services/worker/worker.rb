require 'timeout'
# threadsafe worker class
class Service::Worker
  attr_accessor :succeeded, :model

  def initialize(id: nil, supervisor: nil, klasses: [Feed, FeedItem])
    @running = false                                  # a flag used to stop workers
    @succeeded = false                                # set to true if the worker exits normally
    @id = id                                          # used for logging purposes
    @supervisor = supervisor
    @klasses = klasses                         # set a reference to this worker's supervisor
  end

  # this sets a worker in motion. the worker will stop running
  # if the stop method is called on it, or the queue is empty
  def start
    logger.info "Initializing worker #{@id}..."
    @running = true

    # this is the main loop. workers continue to loop until
    # their stop method is called, or the queue is empty
    while @running
      wait unless dequeue_and_process_element
    end

    logger.info "worker #{@id} finished and exiting"
  end

  # fetches an element from the queue and processes it
  #
  # @return [Boolean] true unless the queue is empty
  def dequeue_and_process_element
    begin
      @error = nil
      @element = dequeue_element

      return false unless @element

      process_element
    rescue StandardError => e
      process_error(e)
    end

    finish_processing

    true
  end

  # Grabs a new Feed or FeedItem from the queue to process
  def dequeue_element
    klass = @klasses.shuffle
    klass.first.dequeue || klass.last.dequeue
  end

  # Logs and processes and element
  def process_element
    logger.info "ELEMENT BEFORE PROCESSING: #{@element.inspect}"
    begin
      Timeout.timeout(300) do
        @element.fetch_and_process
      end
    rescue Timeout::Error,
           StandardError => e
      @element.cleanup_stuck
      process_error(e)
    end
    logger.info "ELEMENT AFTER PROCESSING: #{@element.inspect}"
  end

  # Save an element has been processed
  def finish_processing
    if @element
      begin
        @element.mark_as_processed!
        logger.info "\n after mark_as_processed!"
      rescue => e
        record_error(e)
        update_and_destroy
      end
    end
  end

  # stops the worker after the current iteration
  def stop
    Rails.logger.info "STOPPING WORKER #{@id}!"
    logger.info "STOPPING WORKER #{@id}!"
    @running = false
  end

  def wait
    logger.info 'nothing to do, sleeping...'
    sleep(30)
    logger.info 'waking up!'
  end

  private

  def logger
    return @logger if @logger
    logfile_path = File.join(Rails.root, "log/worker_#{@id}.log")
    # keep up to 5 logfiles, up to 1Mb each
    @logger = Logger.new(logfile_path, 5, 1.megabyte)
    @logger.level = Logger::INFO
    @logger
  end

  # If we can not save an element it must be destroyed
  def update_and_destroy
    stop_processing
    @element.destroy if @element.is_a?(FeedItem)
  end

  # Log exeptions thrown when trying to save an element
  #
  # @param [Exception] exception The expection thrown
  def process_error(exception)
    record_error(exception)
    stop_processing
  end

  def stop_processing
    @element.update(processing: false)
    rescue => e
      record_error(e)
      @element.destroy
  end

  # record an exception, and if the count reaches the threshold,
  # it triggers the error_threshold_reached method also
  # logs the error text to the logfile and on the element itself
  def record_error(exception)
    WorkerError.log(@element, exception)
    @error = exception.message + "\n" + exception.backtrace.join("\n") +
      "\n#{('-' * 90)}\nQUEUE ELEMENT:\n#{@element.inspect}"
    log_error = ('=' * 90) + "\nERROR processing data!" + @error
    logger.error log_error
  end
end
