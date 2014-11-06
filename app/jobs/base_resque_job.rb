require 'resque-retry'

# A base message job to make message sending more simple
class BaseResqueJob
  extend DotConfigure
  extend Resque::Plugins::Retry

  @retry_limit = 3
  @retry_delay = 120

  class << self
    attr_writer :queue

    # Defaults the queue used for this job to low
    def queue

      @queue ||= :low
    end

    # Sets the type objects this job can reveice
    #
    # Example: receives dose: Dose, message: Message
    def receives(**args)
      return @receives if args.empty?
      @receives = args
      @receives.keys.map { |sym| attr_accessor sym }
    end

    # Translates the given IDs to their appropriate objects and then initializes a new Job object
    # with them.  Then it performs the job.
    def perform(*ids)
      new(*ids.each_with_index.map { |id, i| receives.values[i].find(id) }).perform
    end

    # Schedules the job do be run with a set of objects.  If :time is given it will be scheduled
    # at the time, if not it will be run as soon as possible
    def schedule(*args, **opts)
      schedule_by_id(*args.map(&:id), opts)
    end

    # Schedules the job do be run with a set of ids.  If :time is given it will be scheduled
    # at the time, if not it will be run as soon as possible
    def schedule_by_id(*args, **opts)
      time = opts[:time] || Time.now

      Resque.enqueue_at(time, self, *args)
    end
  end

  # Creats a new job instance, sets up instance variables of the names and classes set by `receives`
  # with the ids given
  def initialize(*args)
    args.each_with_index.map { |obj, i| instance_variable_set("@#{self.class.receives.keys[i]}".to_sym, obj) }
  end

  # Forward options to the class
  def options
    self.class.options
  end

  # Fails if not implemented by a subclass
  def perform
    fail 'not implemented'
  end
end
