require 'spec_helper'

describe Spree::GoogleShoppingSetting, shopping_spec: true, story_161: true do
  it { is_expected.to have_db_column(:merchant_id).of_type(:string) }
  it { is_expected.to have_db_column(:oauth2_client_id).of_type(:string) }
  it { is_expected.to have_db_column(:oauth2_client_secret).of_type(:string) }
end