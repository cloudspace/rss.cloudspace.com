module Service
  module Parser
    # parses feeds using feedzirra and provides some handy utility methods
    class Feed < Base
      attr_reader :code, :success, :feed_type, :description, :etag,
                  :feed_url, :url, :hubs, :last_modified, :title

      def initialize(feed_url)
        @feed_url = feed_url
      end

      # uses feedzirra to parse the feed
      def parse
        fzout = Feedzirra::Feed.fetch_and_parse(@feed_url)
        case fzout
        when Fixnum
          @success = false
          @code = fzout
        else
          @success = true
          @code = 200
          @parser = fzout
          @feed_type = fzout.class.to_s.demodulize.underscore
          transcribe_attrs
        end
      end

      # lazily parses and memoizes the feed_items for this feed
      def entries
        @entries ||= @parser.entries.map { |e| Service::Parser::FeedItem.parse(e) }
      end

      # produces a hash of attributes which can be used to create a Feed in rails
      def attributes
        @attributes ||= {}.tap do |attrs|
          attribute_translations.each_pair do |before, after|
            attrs[after] = send(before)
          end
          attribute_transcriptions.each do |var|
            attrs[var] = send(var)
          end
        end
      end

      private

      # fields that are renamed in the attributes (keys are 'before', values 'after')
      def attribute_translations
        { title: :name, last_modified: :last_modified_at, description: :summary }
      end

      # fields that are used as-is in the attributes
      def attribute_transcriptions
        %i{url feed_url etag}
      end

      # properties copied over from @parser verbatim
      def transcribed_fields
        %i{description etag url hubs last_modified title}
      end
    end
  end
end
