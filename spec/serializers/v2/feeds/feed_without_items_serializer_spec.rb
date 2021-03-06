require 'spec_helper'

describe V2::Feeds::FeedWithoutItemsSerializer do
  let(:feed) { FactoryGirl.build(:feed) }
  let(:serializer) { V2::Feeds::FeedWithoutItemsSerializer.new(feed) }

  describe 'json output' do
    subject(:json) { serializer.as_json(root: :feed) }

    it { should have_key :feed }

    describe 'has property' do
      subject(:hash) { json[:feed] }

      it 'id' do
        expect(hash[:id]).to eq(feed.id)
      end

      it 'name' do
        expect(hash[:name]).to eq(feed.name)
      end

      it 'url' do
        expect(hash[:url]).to eq(feed.url)
      end

      it 'site_url' do
        expect(hash[:site_url]).to eq(feed.site_url)
      end

      it 'icon' do
        expect(hash[:icon]).to eq(nil)
      end

    end
  end
end
