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

  describe 'paperclip attachment' do
    describe 'the setup' do
      before do
        @feed_item = FactoryGirl.build(:feed_item)
      end

      it 'has an image paperclip attachment field' do
        expect(@feed_item.image).to be_a(Paperclip::Attachment)
      end

      it 'validates the content type of the attached paperclip image' do
        expect(@feed_item).to validate_attachment_content_type(:image)
          .allowing('image/gif', 'image/jpeg', 'image/png')
          .rejecting('text/plain', 'text/xml')
      end
    end

    # #{RAILS_ROOT}/spec/fixtures/donkey.jpg must exist
    describe 'after attaching the image' do
      before(:all) do
        DatabaseCleaner.start
        donkey = File.open(Rails.root.join('spec', 'fixtures', 'donkey.jpg'))
        @feed_item = FactoryGirl.build(:feed_item, image: donkey)
        donkey.close
      end

      after(:all) do
        DatabaseCleaner.clean
      end

      it 'is valid when the image exists and is a jpg' do
        expect(@feed_item).to be_valid
      end

      it 'has an image url' do
        expect(@feed_item.image.url).not_to be_nil
      end
    end
  end

  describe 'scopes' do
    describe 'processed' do
      before do
        @processed_item = FactoryGirl.create(:feed_item, processed: true)
        @unprocessed_item = FactoryGirl.create(:feed_item, processed: false)

        @returned_feeds = FeedItem.processed
      end

      it 'returns only feed_items which are flagged as processed and none that are not' do
        expect(@returned_feeds).to eq([@processed_item])
      end
    end

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

    describe 'most_recent' do
      before do
        now = DateTime.now
        feed = FactoryGirl.create(:feed)

        @today_feed_item_ids = []
        10.times do
          @today_feed_item_ids << FactoryGirl.create(:feed_item, feed: feed, since: now).id
        end

        @yesterday_feed_item_id = FactoryGirl.create(:feed_item, feed: feed, since: now.yesterday).id
        @returned_feed_item_ids = FeedItem.most_recent(10).pluck(:id).uniq
      end

      it 'returns the 10 most recent feed items' do
        expect(@returned_feed_item_ids).to match_array(@today_feed_item_ids)
        expect(@returned_feed_item_ids).not_to include(@yesterday_feed_item_id)
        expect(@returned_feed_item_ids.length).to eql(10)
      end
    end
  end
end
