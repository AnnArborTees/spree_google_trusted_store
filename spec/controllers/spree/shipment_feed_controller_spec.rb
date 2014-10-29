require 'spec_helper'

describe Spree::ShipmentFeedController, feed_spec: true, story_159: true do
  describe 'GET #feed' do
    let!(:order) { create :shipped_order }

    it 'renders the plaintext order_feed result' do
      allow_any_instance_of(Spree::GoogleTrustedStoreSetting)
        .to receive(:last_feed_upload)
        .and_return 10.days.ago
      allow(controller).to receive(:process_orders)
        .with([order])
        .and_return 'excellent'
      get :feed
      expect(response.body).to eq 'excellent'
    end

    it 'updates the last feed upload date in the settings record' do
      expect_any_instance_of(Spree::GoogleTrustedStoreSetting)
        .to receive(:last_feed_upload=).and_call_original
      expect_any_instance_of(Spree::GoogleTrustedStoreSetting)
        .to receive(:save).and_call_original
      get :feed
    end
  end
end