require 'spec_helper'

describe Feed do
  before(:each) do
    @feed = Feed.new
  end

  describe 'associations' do
    it { expect(@feed).to have_many :feed_items }
  end

  describe 'validations' do
    it { expect(@feed).to validate_presence_of :url }
  end

  describe 'fields' do
    it { expect(@feed).to respond_to :name }
    it { expect(@feed).to respond_to :url }
    it { expect(@feed).to respond_to :site_url }
    it { expect(@feed).to respond_to :summary }
    it { expect(@feed).to respond_to :etag }
    it { expect(@feed).to respond_to :last_modified_at }
    it { expect(@feed).to respond_to :default }
    it { expect(@feed).to respond_to :approved }
    it { expect(@feed).to respond_to :process_start }
    it { expect(@feed).to respond_to :process_end }
  end

  describe 'scopes' do
    describe 'default' do
      before do
        @default_feed = FactoryGirl.create(:feed, default: true)
        @non_default_feed = FactoryGirl.create(:feed, default: false)
      end

      it 'should include default feeds' do
        expect(Feed.default).to include(@default_feed)
      end

      it 'should not include non-default feeds' do
        expect(Feed.default).not_to include(@non_efault_feed)
      end
    end

    describe 'approved' do
      before do
        @approved_feed = FactoryGirl.create(:feed, approved: true)
        @non_approved_feed = FactoryGirl.create(:feed, approved: false)
      end

      it 'should include approved feeds' do
        expect(Feed.approved).to include(@approved_feed)
      end

      it 'should not include non-approved feeds' do
        expect(Feed.approved).not_to include(@non_approved_feed)
      end
    end

    describe 'search_name' do
      before do
        @foo = FactoryGirl.create(:feed, name: 'foo')
        @bar = FactoryGirl.create(:feed, name: 'bar')
        @foobar = FactoryGirl.create(:feed, name: 'foobar')
      end

      it 'should return records that exactly match the specified name' do
        expect(Feed.search_name('foo')).to include(@foo)
      end

      it 'should return records that contain the specified name' do
        expect(Feed.search_name('foo')).to include(@foobar)
      end

      it 'should not return records that do not contain the specified name' do
        expect(Feed.search_name('foo')).not_to include(@bar)
      end
    end

    describe 'fetch_and_process'
    describe 'process_feed_items'
    describe 'queue_next_parse'
  end

  describe 'class methods' do
    describe 'find_or_generate_by_url' do
      let!(:feed_item) { create(:feed_item, process_start: Time.now.days_ago(5)) }
      let!(:feed_item2) { create(:feed_item, feed: feed_item.feed, process_start: Time.now) }

      it 'should join feed items' do
        expect(Feed).to receive(:joins).with(:feed_items).and_call_original
        Feed.items_processed_in_last_days
      end

      it 'should return a hash' do
        expect(Feed.items_processed_in_last_days.class).to be Hash
      end

      it 'should return the feed id and number of feed items processed within 30 years' do
        expect(Feed.items_processed_in_last_days).to eq(feed_item.feed.id => 2)
      end

      it 'should not count feed items outside of passed in range' do
        expect(Feed.items_processed_in_last_days(3)).to eq(feed_item.feed.id => 1)
      end
    end

    describe 'find_or_generate_by_url' do
      before do
        @feed = FactoryGirl.create(:feed)
      end

      it 'should return a pre-existing feed if one already exists with the specified url' do
        Feed.stub(:find_by).with(url: @feed.url).and_return(@feed)
        expect(Feed.find_or_generate_by_url(@feed.url)).to eq(@feed)
      end

      it 'should create and return a new feed if none exists with the specified url' do
        parser = double(Service::Parser::Feed)
        parser.stub(:success?) { true }
        Feed.any_instance.stub(:parser).and_return(parser)
        Feed.any_instance.stub(:fetch_and_process)
        Feed.any_instance.stub(:new_record?).and_return(false)
        expect(Feed.find_or_generate_by_url('foo').class.name).to eq('Feed')
      end

      it 'should throw exception if the parser fails (returns false)' do
        parser = double(Service::Parser::Feed)
        parser.stub(:success?) { false }
        Service::Parser::Feed.any_instance.stub(:parse) { parser }
        Service::Parser::Feed.any_instance.stub(:code) { 0 }
        expect { Feed.find_or_generate_by_url('http://feeds.thingy.com/') }.to raise_error
      end
    end
  end
end
