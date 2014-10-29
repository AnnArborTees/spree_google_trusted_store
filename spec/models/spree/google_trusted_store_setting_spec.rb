require 'spec_helper'

describe Spree::GoogleTrustedStoreSetting, settings_spec: true, story_159: true do
  it { is_expected.to have_db_column(:account_id).of_type(:integer) }
  it { is_expected.to have_db_column(:default_locale).of_type(:string) }
end
