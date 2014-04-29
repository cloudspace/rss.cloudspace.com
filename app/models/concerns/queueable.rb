# Mixin to make an ActiveRecord::Base descendant act as a queue
# requirements:
#   a 'processing' boolean field that defaults to false
#   a 'ready_for_processing' scope which returns items that are ready to be processed
module Queueable
  extend ActiveSupport::Concern

  included do
    # A mutex to lock dequeueing actions at the class level
    @dequeue_mutex ||= Mutex.new

    # returns all feeds that are currently being processed
    scope :processing, -> { where(processing: true) }

    # returns all feeds not currently being processed
    scope :not_processing, -> { where.not(processing: true) }
  end

  # flags an element to indicate it is being processed
  # also accepts additional hash-style arguments with which to update the object
  def lock_element!(**attrs)
    update_attributes(attrs.merge(processing: true))
  end

  # flags an element to indicate it is no longer processing and that it has been processed
  # also accepts additional hash-style arguments with which to update the object
  def mark_as_processed!(**attrs)
    attrs.merge!(processed: true) if self.class.columns.map(&:name).include?('processed')
    unlock_element!(attrs)
  end

  # flags an element to indicate it is no longer processing
  def unlock_element!(**attrs)
    update_attributes(attrs.merge(processing: false))
  end

  # class methods to be mixed in. yay linter.
  module ClassMethods
    # dequeues a single element, marks it for processing, and returns it
    # if there is nothing left on the queue, it returns nil
    # this is a threadsafe, to prevent multiple workers from
    # processing the same element
    #
    # @return [ApiQueue::Element, nil] the element dequeued or nil if queue empty
    def dequeue
      respond_to?(:ready_for_processing) ||
        fail("#{self}.dequeue requires that a :ready_for_processing scope be defined on the model")

      @dequeue_mutex.synchronize do
        element = ready_for_processing.first
        if element
          Rails.logger.info "Dequeueing #{self} element: #{element.inspect}"
          element.lock_element!
        else
          Rails.logger.info "There's nothing to dequeue!"
        end
        element
      end
    end
  end
end
