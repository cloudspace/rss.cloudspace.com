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
                        'url_1422987447993' => "#{feed_item.url}",
                        'prefix_1422987457013' => "feed_items/#{feed_item.id}",
                        'filesecurity_1422987457013' => '',
                        'urlsecurity_1422987457013' => '',
                        'imageprefix_1422987460987' => "feed_items/#{feed_item.id}",
                        'filesecurity_1422987460987' => '',
                        'urlsecurity_1422987460987' => '',
                        'imageprefix_1422987461198' => "feed_items/#{feed_item.id}",
                        'filesecurity_1422987461198' => '',
                        'urlsecurity_1422987461198' => '',
                        'imageprefix_1422987461380' => "feed_items/#{feed_item.id}",
                        'filesecurity_1422987461380' => '',
                        'urlsecurity_1422987461380' => '',
                        'feedid_1422987449016' => "#{feed.id}",
                        'feeditemid_1422987449016' => "#{feed_item.id}",
                        'url_1422987449016' => "#{feed_item.url}",
                        'publishedat_1422987449016' => "#{feed_item.published_at}",
                        'title_1422987449016' => "#{feed_item.title}"
                      }
                    }.to_json,
                    headers: { 'Content-Type' => 'application/json' }
      )
    end
  end
end
