# processes via arbitrary xpath
class Service::Parser::Strategy::Xpath < Service::Parser::Strategy::Base
  def parse
    first_node = document.xpath(@xpath).first
    first_node ? first_node.attr(@attribute) : nil
  end

  def image_url(xpath, attribute = 'src')
    @xpath = xpath
    @attribute = attribute
    parse
  end
end
