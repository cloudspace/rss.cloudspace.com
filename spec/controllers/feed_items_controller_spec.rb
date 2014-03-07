require 'spec_helper'

describe FeedItemsController do

  describe "GET 'feed_items'" do
    it "returns http success" do
      get 'feed_items'
      response.should be_success
    end
  end

end
