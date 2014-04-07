# the parser base class. do not directly instantiate, only for subclassing
class Service::Parser::Base
  include Service::Delegator
  include Service::Attributable

  attr_accessor :options

  # override the default constructor to insert steps before #initialize is called
  def self.new(opts)
    obj = allocate
    obj.options = Service::Options.new(obj.default_options)
    obj.options.deep_merge!(opts)
    obj.send(:initialize)
    obj.parse
    obj
  end

  def default_options
    {}
  end

  def parse(*); end
end
