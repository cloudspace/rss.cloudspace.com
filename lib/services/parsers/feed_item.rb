# wraps feedzirra feed entries and provides some handy utility methods
class Service::Parser::FeedItem < Service::Parser::Base
  attr_reader :feedjira_parser, :metadata_parser, :url
  attributes :title, :url, :author, :summary, :content, published_at: :published
  cache_delegate :title, :author, :summary, :content, :published, :categories, to: :@feedjira_parser

  # accepts a feedjira parser object. constructed by Service::Parser::Feed or by the Parseable concern
  def initialize
    if options.feedjira_parser?
      @url = options.feedjira_parser[:url]
      @feedjira_parser = options.feedjira_parser
    end
  end
end
