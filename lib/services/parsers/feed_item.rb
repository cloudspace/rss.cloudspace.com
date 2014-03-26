require_relative 'base.rb'

module Service
  module Parser
    # wraps feedzirra feed entries and provides some handy utility methods
    class FeedItem < Base
      attr_accessor :title, :author, :summary, :content, :published, :categories, :image, :url
      attributes :image, :title, :url, :author, :summary, :content, published_at: :published
      delegate_methods :title, :author, :summary, :content, :published, :categories, to: :@parser
      delegate_method :image, to: :@image_parser

      # accepts a feedjira parser object. normally only constructed by Service::Parser::Feed
      def initialize(arg)
        case arg
        when String
          @url = arg
          @image_parser = Service::Parser::Metadata.parse(@url)
        else
          @parser = arg
          @url = @parser[:url] && URI(@parser[:url]).normalize.to_s
        end
      end
    end
  end
end
