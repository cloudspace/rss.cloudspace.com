require_relative 'base.rb'

module Service
  module Parser
    # parses feeds using feedjira and provides some handy utility methods
    class Feed < Base
      attr_reader :code, :feed_type, :description, :etag,
                  :site_url, :url, :feed_url, :hubs, :last_modified, :title

      # define the contents of the hash produced by the #attributes instance method
      # array values are placed on the output as keys, hash values are aliased
      attributes :etag, name: :title, last_modified_at: :last_modified,
                        summary: :description, site_url: :url, url: :feed_url

      # define the enumerated methods on instances and delegate calls to them to @fz_feed_parser
      delegate_methods :description, :etag, :url, :feed_url, :hubs, :last_modified, :title, to: :@fz_feed_parser

      # accepts an url
      def initialize(url)
        @url = URI(url).normalize.to_s
      end

      # uses feedjira to parse the feed
      def parse
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

      # lazily parses and memoizes the feed_items for this feed
      def entries
        if defined? @entries
          @entries
        else
          @entries = @fz_feed_parser ? @fz_feed_parser.entries.map { |e| Service::Parser::FeedItem.parse(e) } : []
        end
      end

      # retuens an array of hashes each representing the attributes for a feed ietm in this feed
      def entries_attributes
        entries.map(&:attributes)
      end
    end
  end
end
