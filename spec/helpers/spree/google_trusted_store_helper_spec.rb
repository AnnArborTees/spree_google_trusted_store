require 'spec_helper'

describe Spree::GoogleTrustedStoreHelper, helper_spec: true, story_159: true do
  describe '#google_trusted_store_badge' do
    it 'renders spree/google_trusted_store/badge partial' do
      expect(helper)
        .to receive(:render)
        .with('spree/google_trusted_store/badge', anything)

      helper.google_trusted_store_badge
    end

    it 'passes info based on GoogleTrustedStoreSettings.account_id/default_locale' do
      settings = double('Google Trusted Store Settings',
        account_id: '123987',
        default_locale: 'en_US'
      )
      expect(Spree::GoogleTrustedStoreSetting)
        .to receive(:instance)
        .and_return settings

      expect(helper)
        .to receive(:render)
        .with('spree/google_trusted_store/badge', hash_including(id: '123987', locale: 'en_US'))

      helper.google_trusted_store_badge
    end
  end

  describe '#google_trusted_store_order_confirmation' do
    it 'renders spree/google_trusted_store/order_confirmation partial' do
      expect(helper)
        .to receive(:render)
        .with('spree/google_trusted_store/order_confirmation', anything)

      helper.google_trusted_store_order_confirmation
    end

    it 'assigns locals based on a passed Order object', pending: 'No idea how this will play out'
  end
end
