require_relative 'base.rb'

module Service
  module Parser
    # wraps feedzirra feed entries and provides some handy utility methods
    class FeedItem < Base
      attr_accessor :title, :author, :summary, :content, :published, :categories
      attributes :title, :url, :author, :summary, :content, published_at: :published
      delegate_methods :title, :author, :summary, :content, :published, :categories, to: :fz_entry_parser

      def url
        URI(@fz_entry_parser.url).normalize.to_s
      end

      # accepts a feedzilla parser object. normally only constructed by Service::Parser::Feed
      def initialize(parser)
        @fz_entry_parser = parser
      end
    end
  end
end
