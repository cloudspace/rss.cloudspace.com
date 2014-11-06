require 'timeout'

class FeedProcessingJob << BaseResqueJob
  receives feed: Feed

  def perform
    begin
      Timeout.timeout(300) do
        feed.fetch_and_process
      end
      feed.mark_as_processed!
    rescue Timeout::Error, StandardError => e
      feed.cleanup_stuck
      # record_error(e)
      feed.unlock_element!
    end
  end
end
