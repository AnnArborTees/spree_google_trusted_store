require 'spec_helper'

describe Spree::GoogleTrustedStoreSetting, settings_spec: true, story_159: true do
  it { is_expected.to have_db_column(:account_id).of_type(:string) }
  it { is_expected.to have_db_column(:default_locale).of_type(:string) }

  it { is_expected.to have_db_column(:last_feed_upload).of_type(:datetime) }

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

  describe 'Validations' do
    it 'validates that the length of account_id is 6' do
      settings =  Spree::GoogleTrustedStoreSetting.create
      settings.account_id = '1234'
      expect(settings).to_not be_valid
      settings.account_id = '123456'
      expect(settings).to be_valid
    end
  end

  describe '.create' do
    context 'if there is already an instance' do
      it 'returns that existing instance' do
        expect(
          Spree::GoogleTrustedStoreSetting.create
        )
          .to eq Spree::GoogleTrustedStoreSetting.create

        expect(Spree::GoogleTrustedStoreSetting.count).to eq 1
      end
    end
  end
end
