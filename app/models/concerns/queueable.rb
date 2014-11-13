# Mixin to make an ActiveRecord::Base descendant act as a queue
# requirements:
#   a 'processing' boolean field that defaults to false
#   a 'ready_for_processing' scope which returns items that are ready to be processed
module Queueable
  extend ActiveSupport::Concern

  included do
    # A mutex to lock dequeueing actions at the class level
    # ||= not thread safe
    @dequeue_mutex = Mutex.new unless @dequeue_mutex

    # # returns all feeds that are currently being processed
    # scope :processing, -> { where(processing: true) }

    # returns all feeds not currently being processed
    scope :not_processing, -> { where.not(processing: true) }
  end

  # flags an element to indicate it is being processed
  # also accepts additional hash-style arguments with which to update the object
  def lock_element!(**_attrs)
    update_column(:processing, true)
    update_column(:process_start, Time.now)
  end

  # flags an element to indicate it is no longer processing and that it has been processed
  # also accepts additional hash-style arguments with which to update the object
  def mark_as_processed!(**attrs)
    logger.info "\n in mark_as_processed! before merge"
    update_column(:processed, true) if self.class.columns.map(&:name).include?('processed')
    logger.info "\n in mark_as_processed! before unlock element"
    unlock_element!(attrs)
  end

  # flags an element to indicate it is no longer processing
  def unlock_element!(**_attrs)
    update_column(:scheduled, false)
    update_column(:processing, false)
    update_column(:process_end, Time.now)
  end

  def process_length
    return nil if process_end.nil? || process_start.nil?
    (process_end - process_start) / 60.0
  end

  # class methods to be mixed in. yay linter.
  module ClassMethods
    def process_average
      return 0.0 if count == 0
      all.map(&:process_length).reduce(0.0) { |a, e| a + e }.round(2) / count.to_f
    end
  end
end
