# Mixin to make an ActiveRecord::Base descendant generate its own parser
# requirements:
#   an 'url' field that the parser uses to fetch content
#   a Service::Parser::Base class descendant with the same demodulized class name
module Parseable
  extend ActiveSupport::Concern

  def parser
    @parser ||= "Service::Parser::#{self.class.name}".constantize.parse(url)
  end
end
