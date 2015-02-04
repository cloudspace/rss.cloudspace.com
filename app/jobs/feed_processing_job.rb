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

      HTTParty.post(ENV['MICROSERVICE_API_URL'] + '/jobs',
                    body: {
                      client_id: ENV['MICROSERVICE_API_KEY'],
                      client_secret: ENV['MICROSERVICE_API_SECRET'],
                      flow_name: ENV['MICROSERVICE_FLOW_NAME'],
                      callback: "http://#{ENV['MICROSERVICE_APP_HOST']}/v2/feed_items/#{feed_item.id}/callback",
                      user_params: {
                        'url_1423065187945' => "#{feed_item.url}",
                        'prefix_1423065195783' => "feed_items/#{feed_item.id}",
                        'filesecurity_1423065195783' => '',
                        'urlsecurity_1423065195783' => '',
                        'imageprefix_1423065200633' => "feed_items/#{feed_item.id}",
                        'filesecurity_1423065200633' => '',
                        'urlsecurity_1423065200633' => '',
                        'imageprefix_1423065200846' => "feed_items/#{feed_item.id}",
                        'filesecurity_1423065200846' => '',
                        'urlsecurity_1423065200846' => '',
                        'imageprefix_1423065201027' => "feed_items/#{feed_item.id}",
                        'filesecurity_1423065201027' => '',
                        'urlsecurity_1423065201027' => '',
                        'feedid_1423065188516' => "#{feed.id}",
                        'feeditemid_1423065188516' => "#{feed_item.id}",
                        'url_1423065188516' => "#{feed_item.url}",
                        'publishedat_1423065188516' => "#{feed_item.published_at}",
                        'title_1423065188516' => "#{feed_item.title}"
                      }
                    }.to_json,
                    headers: { 'Content-Type' => 'application/json' }
      )
    end
  end
end
