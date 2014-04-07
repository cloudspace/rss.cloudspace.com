# processes twitter card tags
class Service::Parser::Strategy::Twitter < Service::Parser::Strategy::Base
  def parse
    {}.tap do |out|
      meta_tags.select { |k, v| k['name'] =~ /^twitter:[a-z]+/i }.each do |tag|
        out[tag['name'].sub(/^twitter:/i, '')] = tag['content']
      end
    end
  end

  def image_url
    parse['image']
  end
end
