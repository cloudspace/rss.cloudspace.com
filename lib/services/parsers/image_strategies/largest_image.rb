require 'mini_magick'

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
      if image.large_enough?(@parser.options.image_url.min_size) && (image.area > largest_area) && !is_animated?(image)
        largest_area = image.area
        largest_image_url = image.url
      end
    end
    Rails.logger.info "For URL: #{@parser.url}\nThe Largest Image URL = #{largest_image_url}"
    largest_image_url
  end

  def all_images
    @all_images ||= document.css('img').map { |img| Service::Parser::Image.new(img['src'], @parser.url) }
  end

  def is_animated?(current_image)
    image = MiniMagick::Image.open(current_image.url)
    if(image["format"].casecmp('GIF') == 0)
      # Still images return 2. Animation will be greater.
      if(image["%m:%f %wx%h"].split(" ").size) > 2)
        image.destroy!
        return true
      end
    else
      image.destroy!
      return false
    end
  end
end
