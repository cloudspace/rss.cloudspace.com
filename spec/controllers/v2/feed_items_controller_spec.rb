require 'spec_helper'

describe V2::FeedItemsController do
  describe '#feed_items' do

    # if you set up any feeds for testing, make sure the id does not match one
    # of @bad_feed_ids
    before do
      @bad_feed_ids = [1, 2, 3]
      @good_feed_ids = [4, 5, 6]
      @feeds = @good_feed_ids.each do |id|
        FactoryGirl.create(:feed_with_feed_items, id: id)
      end
    end

    describe 'response status codes' do
      it 'has a 404 response status when no feed ids were provided' do
        get :index
        expect(response.status).to eql(404)
      end

      it 'has a 404 response status when none of the feed ids exist' do
        get :index, feed_ids: @bad_feed_ids
        expect(response.status).to eql(404)
      end

      it 'has a 200 response status when all of the feed ids exist' do
        get :index, feed_ids: @good_feed_ids
        expect(response.status).to eql(200)
      end

      it 'has a 206 response status when some of the feed ids exist' do
        get :index, feed_ids: @good_feed_ids + @bad_feed_ids
        expect(response.status).to eql(206)
      end
    end

    describe 'json responses' do
      context 'all of the feed ids exist' do
        before do
          get :index, feed_ids: @good_feed_ids
          @json = JSON.parse(response.body)
        end

        it 'returns an array of feed items' do
          expect(@json.keys).to include('feed_items')
          expect(@json['feed_items']).to be_an(Array)
        end

        it 'does not return an array of bad feed ids' do
          expect(@json.keys).not_to include('bad_feed_ids')
        end
      end

      context 'some of the feed ids exist' do
        before do
          get :index, feed_ids: @good_feed_ids + @bad_feed_ids
          @json = JSON.parse(response.body)
        end

        it 'returns an array of feed items' do
          expect(@json.keys).to include('feed_items')
          expect(@json['feed_items']).to be_an(Array)
        end

        it 'returns an array of bad feed ids' do
          expect(@json.keys).to include('bad_feed_ids')
          expect(@json['bad_feed_ids']).to be_an(Array)
        end
      end

      context 'no feed items exist for a valid feed id' do
        before do
          @feed_without_feed_items = FactoryGirl.create(:feed, id: 101)
          get :index, feed_ids: [@feed_without_feed_items.id]
          @json = JSON.parse(response.body)
        end

        it 'returns an empty array of feed items' do
          expect(@json.keys).to include('feed_items')
          expect(@json['feed_items']).to match_array([])
        end

        it 'does not return an array of bad feed ids' do
          expect(@json.keys).not_to include('bad_feed_ids')
        end
      end

      context 'requesting feed items since some date' do
        before do
          now = DateTime.now
          tomorrow_feed = FactoryGirl.create(:feed_with_feed_items, id: 102, since: now.tomorrow)
          today_feed = FactoryGirl.create(:feed_with_feed_items, id: 103, since: now)
          yesterday_feed = FactoryGirl.create(:feed_with_feed_items, id: 104, since: now.yesterday)

          # we're expecting feed_tomorrow and feed_today in the output
          #
          # Since the order of the JSON output is potentially
          # nondeterministic, in order to compare the JSON, we need to call
          # JSON.parse on the output of to_json and again on the response body
          # below and then compare the hashes.
          @serialized_feed_items = JSON.parse(V2::FeedItems::FeedItemsSerializer.new(
            feed_items: FeedItem.with_feed_ids([tomorrow_feed.id, today_feed.id])
          ).to_json)

          # trying to pull from feed_yesterday, too, but it shouldn't show up
          get :index,
              feed_ids: [tomorrow_feed.id, today_feed.id, yesterday_feed.id],
              since: now
          @json = JSON.parse(response.body)
        end

        it 'returns an array of feed items at or after some date and not before' do
          expect(@json).to eql(@serialized_feed_items)
        end
      end

      context 'more than 10 feed items exist' do
        before do
          now = DateTime.now
          feed = FactoryGirl.create(:feed_with_feed_items, feed_item_count: 10, since: now)
          yesterday_feed_item = FactoryGirl.create(:feed_item, feed: feed, since: now.yesterday)

          # (Copied from above:) Since the order of the JSON output is
          # potentially nondeterministic, in order to compare the JSON, we need
          # to call JSON.parse on the output of to_json and again on the
          # response body below and then compare the hashes.
          @serialized_today_feed_items = JSON.parse(V2::FeedItems::FeedItemsSerializer.new(
            feed_items: FeedItem.with_feed_ids([feed.id]).where.not(id: yesterday_feed_item.id)
          ).to_json)

          @serialized_yesterday_feed_item = JSON.parse(V2::FeedItems::FeedItemSerializer.new(
            yesterday_feed_item
          ).to_json)

          get :index, feed_ids: [feed.id]
          @json = JSON.parse(response.body)
        end

        it 'returns the 10 most recent feed items' do
          expect(@json['feed_items']).to match_array(@serialized_today_feed_items['feed_items'])
          expect(@json['feed_items']).not_to include(@serialized_yesterday_feed_item)
          expect(@json['feed_items'].length).to eql(10)
        end
      end

      context 'a feed item has an image attachment' do
        it 'returns the url to each image size' do
          pending
        end
      end
    end

  end
end
