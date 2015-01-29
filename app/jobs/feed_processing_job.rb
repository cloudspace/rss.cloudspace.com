require 'timeout'
require 'httparty'

class FeedProcessingJob < BaseResqueJob
  receives feed: Feed
  @queue = :feed

  def perform
    Timeout.timeout(120) do
      process
    end
    feed.mark_as_processed!
  end

  def process
    feed.lock_element!
    feed.fetch_and_process
    feed.feed_items.ready_for_processing.each do |feed_item|
      feed_item.update_attributes(scheduled: true)
      feed_item.lock_element!

      HTTParty.post(ENV['PRODUCTION_MICROSERVICE_API_URL'] + '/jobs',
                    body: {
                      client_id: ENV['PRODUCTION_MICROSERVICE_API_KEY'],
                      client_secret: ENV['PRODUCTION_MICROSERVICE_API_SECRET'],
                      flow_name: ENV['PRODUCTION_FLOW_NAME'],
                      callback: "#{ENV['PRODUCTION_APP_HOST']}/v2/feed_items/#{feed_item.id}/callback",
                      user_params: {
                        'url_0000000000001' => "#{feed_item.url}",
                        's3_prefix_0000000000002' => "feed_items/#{feed_item.id}",
                        'file_security_0000000000002' => '',
                        'url_security_0000000000002' => '',
                        's3_image_prefix_0000000000003' => "feed_items/#{feed_item.id}",
                        'file_security_0000000000003' => '',
                        'url_security_0000000000003' => '',
                        's3_image_prefix_0000000000004' => "feed_items/#{feed_item.id}",
                        'file_security_0000000000004' => '',
                        'url_security_0000000000004' => '',
                        's3_image_prefix_0000000000005' => "feed_items/#{feed_item.id}",
                        'file_security_0000000000005' => '',
                        'url_security_0000000000005' => '',
                        'feed_id_0000000000006' => "#{feed.id}",
                        'feed_item_id_0000000000006' => "#{feed_item.id}",
                        'url_0000000000006' => "#{feed_item.url}",
                        'published_at_0000000000006' => "#{feed_item.published_at}",
                        'title_0000000000006' => "#{feed_item.title}"
                      }
                    }.to_json,
                    headers: { 'Content-Type' => 'application/json' }
      )
    end
  end
end
