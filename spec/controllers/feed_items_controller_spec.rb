require 'spec_helper'

describe V2::FeedItemsController do
  describe '#feed_items' do

    # if you set up any feeds for testing, make sure the id does not match one
    # of @bad_feed_ids
    before(:all) do
      @good_feed_ids = [1, 2, 3]
      @bad_feed_ids = [4, 5, 6]
      @feeds = @good_feed_ids.each do |id|
        FactoryGirl.create(:feed_with_feed_items, id: id)
      end
    end

    context 'response status codes' do
      it 'has a 404 response status when no feed ids were provided' do
        get :feed_items
        expect(response.status).to eql(404)
      end

      it 'has a 404 response status when none of the feed ids exist' do
        get :feed_items, feed_ids: @bad_feed_ids
        expect(response.status).to eql(404)
      end

      it 'has a 200 response status when all of the feed ids exist' do
        get :feed_items, feed_ids: @good_feed_ids
        expect(response.status).to eql(200)
      end

      it 'has a 206 response status when some of the feed ids exist' do
        get :feed_items, feed_ids: @good_feed_ids + @bad_feed_ids
        expect(response.status).to eql(206)
      end
    end

    context 'json responses' do
      context 'all of the feed ids exist' do
        before(:each) do
          get :feed_items, feed_ids: @good_feed_ids
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
        before(:each) do
          get :feed_items, feed_ids: @good_feed_ids + @bad_feed_ids
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
        before(:each) do
          @feed_without_feed_items = FactoryGirl.create(:feed, id: 101)
          get :feed_items, feed_ids: [@feed_without_feed_items.id]
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
        it 'returns an array of feed items at or after some date' do
          pending
        end

        it 'does not return any feed items before some date' do
          pending
        end
      end
    end

  end
end
