require 'spec_helper'

describe Feed do
  before(:each) do
    @feed = Feed.new
  end

  describe 'associations' do
    it { expect(@feed).to have_many :feed_items }
  end

  describe 'validations' do
    it { expect(@feed).to validate_presence_of :feed_url }
  end

  describe 'fields' do
    it { expect(@feed).to respond_to :name }
    it { expect(@feed).to respond_to :url }
    it { expect(@feed).to respond_to :feed_url }
    it { expect(@feed).to respond_to :summary }
    it { expect(@feed).to respond_to :etag }
    it { expect(@feed).to respond_to :last_modified_at }
    it { expect(@feed).to respond_to :default }
    it { expect(@feed).to respond_to :approved }
  end

  describe 'scopes' do
    describe 'default' do
      before(:each) do
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
      before(:each) do
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
      before(:all) do
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
  end
end
