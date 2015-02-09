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
                        'url_1423510413360' => "#{feed_item.url}",
                        'prefix_1423510420705' => "feed_items/#{feed_item.id}",
                        'filesecurity_1423510420705' => '',
                        'urlsecurity_1423510420705' => '',
                        'imageprefix_1423510428827' => "feed_items/#{feed_item.id}",
                        'filesecurity_1423510428827' => '',
                        'urlsecurity_1423510428827' => '',
                        'imageprefix_1423510428530' => "feed_items/#{feed_item.id}",
                        'filesecurity_1423510428530' => '',
                        'urlsecurity_1423510428530' => '',
                        'imageprefix_1423510428164' => "feed_items/#{feed_item.id}",
                        'filesecurity_1423510428164' => '',
                        'urlsecurity_1423510428164' => '',
                        'feedid_1423510414046' => "#{feed.id}",
                        'feeditemid_1423510414046' => "#{feed_item.id}",
                        'url_1423510414046' => "#{feed_item.url}",
                        'publishedat_1423510414046' => "#{feed_item.published_at}",
                        'title_11423510414046' => "#{feed_item.title}"
                      }
                    }.to_json,
                    headers: { 'Content-Type' => 'application/json' }
      )
    end
  end
end
