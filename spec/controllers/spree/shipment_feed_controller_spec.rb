require 'spec_helper'

describe Spree::ShipmentFeedController, feed_spec: true, story_159: true do
  describe 'GET #feed' do
    let!(:order1) { create :shipped_order }
    let!(:order2) { create :shipped_order }

    before :each do
      allow_any_instance_of(Spree::GoogleTrustedStoreSetting)
        .to receive(:last_feed_upload)
        .and_return 10.days.ago
    end

    it 'renders the plaintext order_feed result' do
      allow(controller).to receive(:process_orders)
        .with([order1, order2])
        .and_return 'excellent'
      
      spree_get :feed
      expect(response.body).to eq 'excellent'
    end

    context 'when the user agent is googlebot', agent: true do
      before :each do
        controller.request.env['HTTP_USER_AGENT'] = 'googlebot'
      end

      it 'updates the last feed upload date in the settings record' do
        expect_any_instance_of(Spree::GoogleTrustedStoreSetting)
          .to receive(:last_feed_upload=).and_call_original
        
        expect_any_instance_of(Spree::GoogleTrustedStoreSetting)
          .to receive(:save).and_call_original
        
        spree_get :feed
      end
    end
  end
end