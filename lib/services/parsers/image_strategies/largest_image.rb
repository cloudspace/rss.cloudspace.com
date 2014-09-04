# finds the largest image on the page
class Service::Parser::Strategy::LargestImage < Service::Parser::Strategy::Base
  def parse
    largest_image_url
  end

  def image_url
    if defined? @image_url
      @image_url
    else
      @image_url = parse
    end
  end

  def largest_image_url
    largest_area = 0
    largest_image_url = nil

    all_images.each do |image|
      if image.large_enough?(@parser.options.image_url.min_size) && image.area > largest_area
        largest_area = image.area
        largest_image_url = image.url
      end
    end
    logger.info "For URL: #{@parser.url}\nThe Largest Image URL = #{largest_image_url}"
    largest_image_url
  end

  def all_images
    @all_images ||= document.css('img').map { |img| Service::Parser::Image.new(img['src'], @parser.url) }
  end
end
