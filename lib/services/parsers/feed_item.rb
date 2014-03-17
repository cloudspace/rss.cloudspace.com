module Service
  module Parser
    # wraps feedzirra feed entries and provides some handy utility methods
    class FeedItem < Base
      attr_accessor :title, :url, :author, :summary, :content, :published, :categories

      def initialize(parser)
        @parser = parser
      end

      def parse
        transcribe_attrs
      end

      private

      # properties copied over from the @parser verbatim
      def transcribed_fields
        %i{title url author summary content published categories}
      end
    end
  end
end
