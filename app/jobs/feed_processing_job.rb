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
                        'url_1422991739690' => "#{feed_item.url}",
                        'prefix_1422991781538' => "feed_items/#{feed_item.id}",
                        'filesecurity_1422991781538' => '',
                        'urlsecurity_1422991781538' => '',
                        'imageprefix_1422991787140' => "feed_items/#{feed_item.id}",
                        'filesecurity_1422991787140' => '',
                        'urlsecurity_1422991787140' => '',
                        'imageprefix_1422991787579' => "feed_items/#{feed_item.id}",
                        'filesecurity_1422991787579' => '',
                        'urlsecurity_1422991787579' => '',
                        'imageprefix_1422991787939' => "feed_items/#{feed_item.id}",
                        'filesecurity_1422991787939' => '',
                        'urlsecurity_1422991787939' => '',
                        'feedid_1422991740603' => "#{feed.id}",
                        'feeditemid_1422991740603' => "#{feed_item.id}",
                        'url_1422991740603' => "#{feed_item.url}",
                        'publishedat_1422991740603' => "#{feed_item.published_at}",
                        'title_1422991740603' => "#{feed_item.title}"
                      }
                    }.to_json,
                    headers: { 'Content-Type' => 'application/json' }
      )
    end
  end
end
