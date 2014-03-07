require 'spec_helper'
require 'pp'

describe V2::FeedItemsController do
  before(:all) do
    @feeds = [1, 2, 3].each do |id|
      feed = FactoryGirl.build(:feed_with_feed_items)
      feed.update_attributes(id: id)
      feed.save
    end
  end

  describe "GET /v2/feed_items" do
    # response codes
    it 'returns http not found if no feed ids were provided' do
      get 'feed_items'
      response.response_code.should == 404
    end

    it 'returns http not found if none of the feed ids provided were found' do
      get 'feed_items', { feed_ids: [-1, 'bad feed id', nil] }
      response.response_code.should == 404
    end

    it 'returns http success if all feed ids were found' do
      get 'feed_items', { feed_ids: [1, 2, 3] }
      response.should be_success
    end

    it 'returns http partial content if only some of the feed ids were found' do
      get 'feed_items', { feed_ids: [1, 2, 3, 4] }
      response.response_code.should == 206
    end

    # json responses
    it 'only returns feeds since the provided date' do
      pending
    end

    it 'returns an array of feed items on success' do
      pending
    end

    it 'returns an array of feed items and an array of bad feed ids on partial success' do
      pending
    end
  end

end
