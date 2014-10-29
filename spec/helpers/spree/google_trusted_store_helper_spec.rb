require 'spec_helper'

describe Spree::GoogleTrustedStoreHelper, helper_spec: true, story_159: true do
  describe '#google_trusted_store_badge' do
    it 'renders spree/google_trusted_store/badge partial' do
      expect(helper)
        .to receive(:render)
        .with('spree/google_trusted_store/_badge', anything)

      helper.google_trusted_store_badge
    end

    it 'passes info based on GoogleTrustedStoreSettings.account_id/default_locale' do
      expect(Spree::GoogleTrustedStoreSettings).to receive(:account_id)
        .and_return '123987'
      expect(Spree::GoogleTrustedStoreSettings).to receive(:default_locale)
        .and_return 'en_US'

      expect(helper)
        .to receive(:render)
        .with('spree/google_trusted_store/_badge', hash_including(id: '123987', locale: 'en_US'))

      helper.google_trusted_store_badge
    end
  end

  describe '#google_trusted_store_order_confirmation' do
    it 'renders spree/google_trusted_store/_order_confirmation partial' do
      expect(helper)
        .to receive(:render)
        .with('spree/google_trusted_store/_order_confirmation', anything)

      helper.google_trusted_store_order_confirmation
    end

    it 'assigns locals based on a passed Order object', pending: 'No idea how this will play out'
  end
end
