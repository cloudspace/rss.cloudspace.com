# a simple class to allow analyzing an image at a given url
class Service::Parser::Image
  attr_reader :url

  # the context (url of the page the image is on) is required to
  # properly resolve images with relative uri's
  def initialize(uri, context = nil)
    @url = absolutize_resource(uri, context)
  end

  # returns an array (pair) of integer dimensions, like [300, 400]
  def dimensions
    if defined? @dimensions
      @dimensions
    else
      @dimensions = FastImage.size(@url, timeout: 20)
    end
  end

  # returns false if either dimension is less than min
  def large_enough?(min)
    dimensions ? dimensions.min >= min : false
  end

  # returns the area, or the product of the dimensions
  def area
    dimensions ? dimensions.reduce(:*) : 0
  end

  def to_str
    @url
  end

  alias_method :to_s, :to_str

  private

  # 'absolutizes' relative uri's to ensure they are fully specfied
  # with host and scheme. return absolute urls unmodified
  def absolutize_resource(uri, context)
    parsed_uri = URI.parse(uri)
    if parsed_uri.relative?
      fail ::RelativeURIError, "context required to parse #{uri.inspect}" unless context
      context = URI.parse(context)

      build_from_parsed_context(parsed_uri, context)
    else
      uri
    end
  end

  def build_from_parsed_context(parsed_uri, context)
    host = "#{context.scheme}://#{context.host}"
    query = parsed_uri.query ? "?#{parsed_uri.query}" : ''
    "#{host}#{parsed_uri.path}#{query}"
  end
end

class ImageParseError < RuntimeError; end
class RelativeURIError < ImageParseError; end
