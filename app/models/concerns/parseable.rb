# Mixin to make an ActiveRecord::Base descendant generate its own parser
# requirements:
#   an 'url' field that the parser uses to fetch content
#   a :parse_options method which returns a hash of default parse options or nil for defaults
#   a Service::Parser::Base class descendant with the same demodulized class name
module Parseable
  extend ActiveSupport::Concern

  def parser
    if defined? @cached_parser
      @cached_parser
    else
      @cached_parser = parser_class.new((parser_options || {}).merge(url: url))
    end
  end

  def parser_class
    parser_type = self.class.instance_variable_get(:@parser_type)
    class_name = parser_type ? "Service::Parser::#{parser_type.to_s.camelize}" : "Service::Parser::#{self.class.name}"
    class_name.constantize
  end
end
