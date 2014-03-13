require 'spec_helper'

describe V2::FeedsController do
  # describe "#feed_items" do
  #   before(:all) do
  #     @feeds = [1, 2, 3].each do |id|
  #       feed = FactoryGirl.create(:feed_with_feed_items, id: id)
  #     end
  #   end
  #
  #   # response codes
  #   it 'has 404 status code when no feed ids were provided' do
  #     get :feed_items
  #     expect(response.status).to eql(404)
  #   end
  #
  #   it 'has 404 status code when none of the feed ids exist' do
  #     get :feed_items, { feed_ids: [-1, 'bad feed id', nil] }
  #     expect(response.status).to eql(404)
  #   end
  # end

  describe '#default' do
    before(:each) do
      @default_feed = FactoryGirl.create(:feed, default: true)
      @normal_feed = FactoryGirl.create(:feed, default: false)

      get :default
    end

    it 'should return a 200' do
      expect(response.status).to eq(200)
    end

    it 'returns only default feeds and not normal feeds' do
      feeds = JSON.parse(response.body)['feeds']
      expect(feeds.map { |f| f['id'] }).to eq([@default_feed.id])
    end
  end

  describe '#search' do
    before(:each) do
      @foo = FactoryGirl.create(:feed, default: true, name: 'foo')
      @bar = FactoryGirl.create(:feed, default: false, name: 'bar')
      @foobar = FactoryGirl.create(:feed, default: false, name: 'foobar')
    end

    it 'should return 400 if no name parameter is specified' do
      get :search
      expect(response.status).to eq(400)
    end

    it 'should return 200 if a name is specified' do
      get :search, name: 'baz'
      expect(response.status).to eq(200)
    end

    it 'should return only feeds with name attributes containing "name" parameter' do
      get :search, name: 'foo'

      feed_ids = JSON.parse(response.body)['feeds'].map { |f| f['id'] }
      expect(feed_ids).to include(@foo.id)
      expect(feed_ids).to include(@foobar.id)
      expect(feed_ids).not_to include(@bar.id)
    end
  end

  describe 'create' do
    it 'should return a 400 if no url parameter is provided' do
      post :create
      expect(response.status).to eq(400)
    end

    it 'should return a 422 if the url cannot be processed' do
      Feed.stub(:generate_from_url).and_return(false)
      post :create, url: 'foo'
      expect(response.status).to eq(422)
    end

    it 'should return a 201 if the feed was created sucessfully' do
      Feed.stub(:generate_from_url).and_return(true)
      post :create, url: 'foo'
      expect(response.status).to eq(201)
    end
  end
end
