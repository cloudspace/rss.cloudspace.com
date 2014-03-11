require 'spec_helper'

describe FeedItem do
  before(:all) do
    @feed_item = FeedItem.new
  end

  describe 'associations' do
    it { expect(@feed_item).to belong_to :feed }
  end

  describe 'validations' do
    it { expect(@feed_item).to validate_presence_of :title }
    it { expect(@feed_item).to validate_presence_of :url }
  end

  describe 'fields' do
    it { expect(@feed_item).to respond_to :id }
    it { expect(@feed_item).to respond_to :title }
    it { expect(@feed_item).to respond_to :url }
    it { expect(@feed_item).to respond_to :author }
    it { expect(@feed_item).to respond_to :summary }
    it { expect(@feed_item).to respond_to :content }
    it { expect(@feed_item).to respond_to :published_at }
    it { expect(@feed_item).to respond_to :feed_id }
    it { expect(@feed_item).to respond_to :created_at }
    it { expect(@feed_item).to respond_to :updated_at }
  end

  describe 'scopes' do
    describe 'with_feed_ids' do
      before(:all) do
        @these_feed_ids = [1, 2, 3]
        @these_feeds = @these_feed_ids.each do |id|
          FactoryGirl.create(:feed_with_feed_items, id: id)
        end

        @not_these_feed_ids = [4, 5, 6]
        @not_these_feeds = @not_these_feed_ids.each do |id|
          FactoryGirl.create(:feed_with_feed_items, id: id)
        end

        # TODO this is awful
        @returned_feed_ids = FeedItem.with_feed_ids(@these_feed_ids).map(&:feed_id).uniq
      end

      it 'returns only the requested feed ids' do
        expect(@returned_feed_ids).to match_array(@these_feed_ids)
      end
    end

    describe 'since' do
      before(:all) do
      end

      it 'returns feed items at or after some date and not before' do
        pending
      end
    end
  end
end
