require 'spec_helper'

describe Spree::GoogleTrustedStoreSetting, settings_spec: true, story_159: true do
  it { is_expected.to have_db_column(:account_id).of_type(:string) }
  it { is_expected.to have_db_column(:default_locale).of_type(:string) }

  describe 'Default values' do
    describe 'account_id' do
      it 'defaults to "000000"' do
        expect(Spree::GoogleTrustedStoreSetting.create.account_id).to eq '000000'
      end
    end

    describe 'default_locale' do
      it 'defaults to "en_US"' do
        expect(Spree::GoogleTrustedStoreSetting.create.default_locale).to eq 'en_US'
      end
    end
  end

  describe 'Valudations' do
    it { is_expected.to validate_length_of(:account_id).is(6) }
  end
end
