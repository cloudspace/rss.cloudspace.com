require 'spec_helper'

describe V2::FeedsController, type: :controller do
  describe '#show' do
    let(:feed) { FactoryGirl.create(:feed) }

    it 'should return 200' do
      get :show, id: feed.id
      expect(response.status).to eq(200)
    end

    it 'should return only the feed specified' do
      get :show, id: feed.id
      feed_ids = JSON.parse(response.body)['feeds'].map { |f| f['id'] }
      expect(feed_ids).to eq([feed.id])
    end

    it 'should return 404 if the feed with the specified id does not exist' do
      get :show, id: feed.id + 1
      expect(response.status).to eq(404)
    end
  end

  describe '#default' do
    before do
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
    before do
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

  describe '#create' do
    let(:feed) { FactoryGirl.create(:feed) }

    it 'should return a 400 if no url parameter is provided' do
      post :create
      expect(response.status).to eq(400)
    end

    it 'should return a 422 if the url cannot be processed' do
      Feed.stub(:find_or_generate_by_url).and_return(false)
      post :create, url: 'foo'
      expect(response.status).to eq(422)
    end

    it 'should return a 200 with a feed if a feed with the same url already existed' do
      Feed.stub(:find_with_url).with('foo').and_return(feed)
      post :create, url: 'foo'
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)['feeds'].map { |f| f['id'] }).to eq([feed.id])
    end

    it 'should return a 201 with a feed if the feed did not exist and was created sucessfully' do
      Feed.stub(:find_by).with(url: 'foo').and_return(nil)
      Feed.stub(:find_or_generate_by_url).and_return(feed)
      post :create, url: 'foo'
      expect(response.status).to eq(201)
      expect(JSON.parse(response.body)['feeds'].map { |f| f['id'] }).to eq([feed.id])
    end
  end
end
