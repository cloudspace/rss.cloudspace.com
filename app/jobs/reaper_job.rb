class ReaperJob < BaseResqueJob
  @queue = :reaper

  def perform
    FeedItem.cull!
  end
end
