# the parser base class. do not directly instantiate, only for subclassing
class Service::Parser::Base
  include Service::Delegator
  include Service::Attributable

  attr_accessor :options, :code

  # override the default constructor to insert steps before #initialize is called
  def self.new(opts)
    obj = allocate
    obj.options = Service::Options.new(obj.default_options).deep_merge!(opts)
    obj.send(:initialize)
    obj.parse
    parse_exceptions(obj.code) if obj.code && (obj.code >= 400 || obj.code == 0)
    obj
  end

  PARSER_EXCEPTIONS = {
    0 => 'Not a URL',
    400 => 'Bad Request',
    401 => 'Unauthorized',
    403 => 'Forbidden',
    404 => 'Not Found',
    408 => 'Timeout',
    500 => 'Internal Server Error',
    502 => 'Bad Gateway',
    503 => 'Server Unavailable',
    504 => 'Gateway Timeout'
  }

  def self.parse_exceptions(code)
    fail PARSER_EXCEPTIONS[code]
  end

  def default_options
    {}
  end

  def parse(*); end
end
