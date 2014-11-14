require 'spec_helper'

RSpec.describe Setting, type: :model do
  let(:instance) { build(:setting) }
  let(:cache) { double }

  before :each do
    allow(Setting).to receive(:instance) { instance }
    allow(instance).to receive(:cache) { cache }
    allow(cache).to receive(:fetch) { 2 }
  end

  describe 'returns results for valid setting' do
    it { expect(Setting.backoff_min).to eql(2) }
  end

  describe 'does not return results for invalid settings' do
    it { expect(Setting.backoff_min).not_to eql(3) }
  end

  pending 'caches valid setting results'

  pending 'updates setting results after changes to the database'

end
