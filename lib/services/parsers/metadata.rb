require_relative 'base.rb'

module Service
  module Parser
    # parses documents for opengraph and twitter metadata, as well as the largest image
    class Metadata < Base
      def initialize(url)
        @url = url
      end

      def image
        largest_image_url ? open(largest_image_url) : nil
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

      def og
        @og ||= {}.tap do |out|
          meta_tags.select { |k, v| k['property'] =~ /^og:[a-z]+/i }.each do |tag|
            out[tag['property'].sub(/^og:/i, '')] = tag['content']
          end
        end
      end

      def twitter
        @twitter ||= {}.tap do |out|
          meta_tags.select { |k, v| k['name'] =~ /^twitter:[a-z]+/i }.each do |tag|
            out[tag['name'].sub(/^twitter:/i, '')] = tag['content']
          end
        end
      end

      # def microdata
      #   scopes = document.xpath("//*[@itemscope]")
      #   scopes.map do |scope|
      #     scope.xpath("//*[@itemprop]").map do |prop|
      #       prop.content
      #     end
      #   end
      # end

      def largest_image_url(min: 25)
        largest_area = 0
        @largest_image_url = nil

        all_images.each do |img_url|
          dimensions = FastImage.size(img_url)
          if dimensions && dimensions.min >= min
            size = dimensions.reduce(:*)
            if size > largest_area
              largest_area = size
              @largest_image_url = img_url
            end
          end
        end

        @largest_image_url
      end

      def all_images
        @all_images ||= document.css('img').map { |image| image['src'] } + [*twitter['image']] + [*og['image']]
      end
    end
  end
end
