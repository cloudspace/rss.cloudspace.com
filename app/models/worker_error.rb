# yay linter
class WorkerError < ActiveRecord::Base
  belongs_to :element, polymorphic: true
  
  after_save :update_feed_count

  def self.log(element, exception)
    create(element: element,
           element_state: element.inspect,
           message: exception.message,
           exception_class: exception.class.to_s,
           backtrace: exception.backtrace.join("\n"))
  end

  def self.glance
    msgs = pluck(:message)
    Rails.logger.info '=' * 80
    Rails.logger.info msgs.uniq.map { |msg| "(#{msgs.count(msg)}) #{msg}" }.join("\n#{'-' * 80}\n")
    Rails.logger.info '=' * 80
    nil
  end

  def show
    Rails.logger.info [exception_class, message, element_state, backtrace].join("\n#{'-' * 80}\n")
  end

  private

  def update_feed_count
    element.update_attribute(:feed_errors_count, element.feed_errors_count+1) if element_type == 'Feed'
  end
end
