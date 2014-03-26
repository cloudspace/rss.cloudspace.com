# yay linter
class WorkerError < ActiveRecord::Base
  belongs_to :element, polymorphic: true

  def self.log(element, exception)
    create(element: element,
           element_state: element.inspect,
           message: exception.message,
           backtrace: exception.backtrace.join("\n"))
  end

  def self.glance
    Rails.logger.info '=' * 80
    msgs = pluck(:message)
    Rails.logger.info msgs.uniq.map { |msg| "(#{msgs.count(msg)}) #{msg}" }.join("\n#{'-' * 80}\n")
    Rails.logger.info '=' * 80
    nil
  end

  def show
    Rails.logger.info [message, element_state, backtrace].join("\n#{'-' * 80}\n")
  end
end
