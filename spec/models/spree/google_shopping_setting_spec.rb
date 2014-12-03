require 'spec_helper'

describe Spree::GoogleShoppingSetting, shopping_spec: true, story_161: true do
  it { is_expected.to have_db_column(:merchant_id).of_type(:string) }
  it { is_expected.to have_db_column(:oauth2_client_id).of_type(:string) }
  it { is_expected.to have_db_column(:oauth2_client_secret).of_type(:string) }

  it { is_expected.to have_db_column(:current_access_token).of_type(:string) }
  it { is_expected.to have_db_column(:current_refresh_token).of_type(:string) }
  it { is_expected.to have_db_column(:current_expiration_date).of_type(:datetime) }

  it { is_expected.to have_db_column(:google_api_application_name).of_type(:string) }
  it { is_expected.to have_db_column(:use_google_shopping).of_type(:boolean) }
end
