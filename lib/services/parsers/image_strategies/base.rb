# base parser strategy class
class Service::Parser::Strategy::Base
  include Service::Delegator

  cache_delegate :document, :meta_tags, to: :@parser

  def initialize(parser)
    @parser = parser
  end

  def parse(*); end
end
