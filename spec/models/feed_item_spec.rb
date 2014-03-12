require 'spec_helper'

describe FeedItem do
  describe 'the model itself' do
    before do
      @feed_item = FactoryGirl.build(:feed_item)
    end

    it 'has a valid factory' do
      expect(@feed_item).to be_valid
    end

    it 'belongs to feed' do
      expect(@feed_item).to belong_to :feed
    end

    it 'validates the presence of title' do
      @feed_item.title = nil
      expect(@feed_item).not_to be_valid
    end

    it 'validates the presence of url' do
      @feed_item.url = nil
      expect(@feed_item).not_to be_valid
    end

    it 'validates the presence of feed/feed_id' do
      @feed_item.feed = nil
      @feed_item.feed_id = nil
      expect(@feed_item).not_to be_valid
    end
  end

  describe 'image paperclip attachment' do
    before do
      @feed_item = FactoryGirl.build(:feed_item)
    end

    it 'has an image paperclip attachment field' do
      expect(@feed_item.image).to be_a(Paperclip::Attachment)
    end

    it 'validates the attached paperclip image' do
      expect(@feed_item).to validate_attachment_content_type(:image).
        allowing('image/gif', 'image/jpeg', 'image/png').
        rejecting('text/plain', 'text/xml')
    end
  end

  describe 'scopes' do
    describe 'with_feed_ids' do
      before do
        @these_feed_ids = [1, 2, 3]
        @these_feed_ids.each do |id|
          FactoryGirl.create(:feed_with_feed_items, id: id)
        end

        @not_these_feed_ids = [4, 5, 6]
        @not_these_feed_ids.each do |id|
          FactoryGirl.create(:feed_with_feed_items, id: id)
        end

        @returned_feed_ids = FeedItem.with_feed_ids(@these_feed_ids).pluck(:feed_id).uniq
      end

      it 'returns the feed items with the requested feed ids' do
        expect(@returned_feed_ids).to match_array(@these_feed_ids)
        expect(@returned_feed_ids).not_to include(*@not_these_feed_ids)
      end
    end

    describe 'since' do
      before do
        now = DateTime.now

        @tomorrow_feed_item_ids = [1, 2, 3]
        @tomorrow_feed_item_ids.each do |id|
          FactoryGirl.create(:feed_item, id: id, since: now.tomorrow)
        end

        @today_feed_item_ids = [4, 5, 6]
        @today_feed_item_ids.each do |id|
          FactoryGirl.create(:feed_item, id: id, since: now)
        end

        @yesterday_feed_item_ids = [7, 8, 9]
        @yesterday_feed_item_ids.each do |id|
          FactoryGirl.create(:feed_item, id: id, since: now.yesterday)
        end

        @returned_feed_item_ids = FeedItem.since(now).pluck(:id).uniq
      end

      it 'returns feed items at or after some date and not before' do
        expect(@returned_feed_item_ids).to match_array(@tomorrow_feed_item_ids + @today_feed_item_ids)
        expect(@returned_feed_item_ids).not_to include(*@yesterday_feed_item_ids)
      end
    end
  end
end
