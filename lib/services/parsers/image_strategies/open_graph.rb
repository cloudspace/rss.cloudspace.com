# processes opengraph tags
class Service::Parser::Strategy::OpenGraph < Service::Parser::Strategy::Base
  def parse
    {}.tap do |out|
      meta_tags.select { |k, _v| k['property'] =~ /^og:[a-z]+/i }.each do |tag|
        out[tag['property'].sub(/^og:/i, '')] = tag['content']
      end
    end
  end

  def image_url
    parse['image']
  end
end
