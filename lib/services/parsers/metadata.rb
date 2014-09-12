# parses documents for opengraph and twitter metadata, as well as the largest image
class Service::Parser::Metadata < Service::Parser::Base
  attr_reader :url
  attributes :image_url

  def initialize
    @url = options[:url]
    @strategies = {}
  end

  # specify options with an array or single instance of:
  #   a symbol or string denoting the name of the strategy
  #   a hash like {name: 'strategy_name', args: [arg1, arg2]}, where
  #     - args are passed to the relevant method on the strategy, if present
  #     - args may be omitted or nil (but in this case just use the string/symbol syntax instead)
  # the defaults demonstrate a few different ways to specify options
  def default_options
    {
      image_url: {
        min_size: 300,
        strategies: [
          :open_graph,
          { name: :twitter },
          { name: :largest_image, args: [] }
        ]
      }
    }
  end

  def raw_page
    @raw_page ||= HTTParty.get(@url).body
  end

  def document
    @document ||= Nokogiri::HTML(raw_page)
  end

  def meta_tags
    @meta_tags ||= document.xpath('//meta').map do |meta|
      {}.tap do |out|
        meta.attribute_nodes.each do |node|
          out[node.name] = node.value
        end
      end
    end
  end

  def strategy(strategy_name)
    strategy_name = strategy_name.to_sym
    return @strategies[strategy_name] if @strategies.key?(strategy_name)
    klass = "Service::Parser::Strategy::#{strategy_name.to_s.camelize}".constantize
    @strategies[strategy_name] = klass.new(self)
  end

  def image_url
    strategies = [*options.image_url.strategies]
    strategies.each do |strat|
      result = case strat
               when Symbol, String
                 strategy(strat).image_url
               when Hash
                 strategy(strat[:name]).image_url(*[*strat[:args]].compact)
               end
      return result if result && image_valid?(result)
    end
    nil
  end

  def image_valid?(result)
    min_size = options.image_url.min_size || 0
    image = Service::Parser::Image.new(result, @url)
    image.large_enough?(min_size) && !image.animated?
  end

end
