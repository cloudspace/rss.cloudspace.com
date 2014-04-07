# threadsafe worker class
class Service::Worker
  attr_accessor :succeeded, :model

  def initialize(id: nil, supervisor: nil)
    @running = false                                  # a flag used to stop workers
    @succeeded = false                                # set to true if the worker exits normally
    @id = id                                          # used for logging purposes
    @supervisor = supervisor                          # set a reference to this worker's supervisor
  end

  # this sets a worker in motion. the worker will stop running
  # if the stop method is called on it, or the queue is empty
  def start
    # this allows interrupts to be caught and stop the workers
    # there has to be a better way than this, but i couldn't
    # figure out how
    # TODO: find a better way to handle interrupts gracefully
    Kernel.trap('INT') { @supervisor.stop_workers }

    log "Initializing worker #{@id}..."
    @running = true

    # this is the main loop. workers continue to loop until
    # their stop method is called, or the queue is empty
    while @running
      wait unless dequeue_and_process_element
    end

    log "worker #{@id} finished and exiting"
  end

  # fetches an element from the queue and processes it
  #
  # @return [Boolean] true unless the queue is empty
  def dequeue_and_process_element
    begin
      @error = nil
      @element = Feed.dequeue || FeedItem.dequeue
      log "ELEMENT BEFORE PROCESSING: #{@element.inspect}"
      return false unless @element

      log "processing #{@element.class} #{@element.id}..."
      @element.fetch_and_process
    rescue StandardError => e
      record_error(e)
    ensure
      @element.mark_as_processed! if @element
    end
    log "ELEMENT AFTER PROCESSING: #{@element.inspect}"
    true
  end

  # stops the worker after the current iteration
  def stop
    Rails.logger.info "STOPPING WORKER #{@id}!"
    log "STOPPING WORKER #{@id}!"
    @running = false
  end

  def wait
    log 'nothing to do, sleeping...'
    sleep(30)
    log 'waking up!'
  end

  private

  # logs text into the logfile corresponding to the worker's @id
  #
  # @param [String] text the text to be logged
  def log(text)
    File.open("log/worker#{(@id ? '_' + @id.to_s : '')}.log", 'a') { |f| f.puts(text) }
  end

  # record an exception, and if the count reaches the threshold,
  # it triggers the error_threshold_reached method also
  # logs the error text to the logfile and on the element itself
  def record_error(exception)
    WorkerError.log(@element, exception)
    @error = exception.message + "\n" + exception.backtrace.join("\n") +
      "\n#{('-' * 90)}\nQUEUE ELEMENT:\n#{@element.inspect}"
    log(('=' * 90) + "\nERROR processing data!" + @error)
  end
end
