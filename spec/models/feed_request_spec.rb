require 'spec_helper'

describe FeedRequest do
  before(:each) do
    @feed_request = FeedRequest.new
  end

  describe 'associations' do
    it { expect(@feed_request).to belong_to :feed }
  end

  describe 'validations' do
    it { expect(@feed_request).to validate_presence_of :feed_id }
  end

  describe 'fields' do
    it { expect(@feed_request).to respond_to :count }
  end

  describe 'instance methods' do
    describe 'count_update' do
      before do
        @feed_request = create(:feed_request)
      end

      it 'should add 1 to current count' do
        expect(@feed_request.count).to eq(0)
        @feed_request.count_update
        expect(@feed_request.count).to eq(1)
      end
    end
  end
end
