require 'mini_magick'

# finds the largest image on the page
class Service::Parser::Strategy::LargestImage < Service::Parser::Strategy::Base

  def logger
    self.class.logger
  end

  def self.logger
    return @logger if @logger
    logfile_path = File.join(Rails.root, 'log/largest_image.log')
    # keep up to 5 logfiles, up to 1Mb each
    @logger = Logger.new(logfile_path, 5, 1.megabyte)
    @logger.level = Logger::INFO
    @logger
  end

  def parse
    url = largest_image_url
    logger.info "For URL: #{@parser.url}\nThe Largest Image URL = #{url}"
    url
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
      next unless image.large_enough?(@parser.options.image_url.min_size) &&
                (image.area > largest_area) && !image.animated?
      largest_area = image.area
      largest_image_url = image.url
    end

    largest_image_url
  end

  def all_images
    return if @all_images
    @all_images = document.css('img').map { |img| Service::Parser::Image.new(img['src'], @parser.url) }
  end
end
