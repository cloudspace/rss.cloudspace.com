# parses feeds using feedjira and provides some handy utility methods
class Service::Parser::Feed < Service::Parser::Base
  attributes :etag, name: :title, last_modified_at: :last_modified,
                    summary: :description, site_url: :url, url: :feed_url
  cache_delegate :description, :etag, :url, :feed_url, :hubs, :last_modified, :title, to: :@fz_feed_parser

  # accepts an url
  def initialize
    @url = URI(options.url).normalize.to_s
  end

  # uses feedjira to parse the feed
  # and capture and cache the output
  def parse
    # fzout = Feedjira::Feed.parse(fetch)
    fzout = Feedjira::Feed.fetch_and_parse(@url)
    case fzout
    when Fixnum
      @success = false
      @code = fzout
    else
      @success = true
      @code = 200
      @fz_feed_parser = fzout
      @feed_type = fzout.class.to_s.demodulize.underscore
    end
  end

  # memoizes and returns the raw xml for the feed
  def fetch
    @raw_feed = HTTParty.get(@url).response.body if !@raw_feed
  end

  # a simple alias method. was the parsing successful?
  def success?
    !!@success
  end

  # lazily parses and memoizes the feed_items for this feed
  def entries
    if defined? @entries
      @entries
    else
      if @fz_feed_parser && @fz_feed_parser.entries
        @entries = @fz_feed_parser.entries.map { |e| Service::Parser::FeedItem.new(feedjira_parser: e) }
      else
        []
      end
    end
  end

  # retuens an array of hashes each representing the attributes for a feed ietm in this feed
  def entries_attributes
    entries.map(&:attributes)
  end
end
