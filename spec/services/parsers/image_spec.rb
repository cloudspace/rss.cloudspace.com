require 'spec_helper'

describe Service::Parser::Image do
  describe '#initialize' do
    it 'should "absolutize" a relative image uri if a context is provided' do
      image = Service::Parser::Image.new('/images/sample.jpeg', 'http://foo.com')
      expect(image.url).to eq('http://foo.com/images/sample.jpeg')
    end

    it 'should raise an exception if a relative url is passed with no context' do
      expect { Service::Parser::Image.new('/images/sample.jpeg') }.to raise_error(RelativeURIError)
    end

    it 'should not modify an absolute url' do
      url = 'http://foo.com/images/sample.jpeg'
      image = Service::Parser::Image.new(url)
      expect(image.url).to eq(url)
    end
  end

  describe '#dimensions' do
    it 'should call FastImage.size' do
      url = 'http://foo.com/images/sample.jpeg'
      image = Service::Parser::Image.new(url)
      expect(FastImage).to receive(:size).with(url, timeout: 20)
      image.dimensions
    end
  end

  describe '#large_enough?' do
    before(:each) do
      @url = 'http://foo.com/images/sample.jpeg'
      @image = Service::Parser::Image.new(@url)
    end

    it 'should return true if the argument is smaller than the smallest dimension' do
      @image.stub(:dimensions) { [300, 400] }
      expect(@image.large_enough?(250)).to be_true
    end

    it 'should return true if the argument is equal to the the smallest dimension' do
      @image.stub(:dimensions) { [300, 400] }
      expect(@image.large_enough?(300)).to be_true
    end

    it 'should return false if the argument is larger than one dimension' do
      @image.stub(:dimensions) { [300, 400] }
      expect(@image.large_enough?(350)).to be_false
    end

    it 'should return false if the argument is larger than both dimensions' do
      @image.stub(:dimensions) { [300, 400] }
      expect(@image.large_enough?(450)).to be_false
    end

    it 'should return false if #dimensions returns nil for any reason' do
      @image.stub(:dimensions) { nil }
      expect(@image.large_enough?(450)).to be_false
    end
  end

  describe '#area' do
    it 'should return the product of the dimensions'
    it 'should return 0 if #dimensions returns nil'
  end

  describe '#to_s' do
    it '#should return the image url as a string'
  end
end
