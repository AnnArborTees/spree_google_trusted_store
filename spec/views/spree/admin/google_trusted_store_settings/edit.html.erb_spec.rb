require 'spec_helper'

describe 'spree/admin/google_trusted_store_settings/edit.html.erb', settings_spec: true, story_159: true do
  before(:each) do
    allow(view.spree).to receive(:admin_general_settings_path)
      .and_return 'http://duhh.com/'
    allow(view.spree).to receive(:google_trusted_store_shipment_feed_url)
      .and_return 'shipment feed url'
    allow(view.spree).to receive(:google_trusted_store_cancelation_feed_url)
      .and_return 'cancelation feed url'
  end

  it 'displays a text field for account_id and default_locale' do
    assign(:google_trusted_store_setting, Spree::GoogleTrustedStoreSetting.create)
    render template: 'spree/admin/google_trusted_store_settings/edit'

    expect(rendered).to have_css 'input[type="text"][name="google_trusted_store_setting[account_id]"]'
    expect(rendered).to have_css 'input[type="text"][name="google_trusted_store_setting[default_locale]"]'
  end

  context 'when a user has sufficient permissions' do
    # TODO actually require permissions

    it 'shows the url for shipment automatic upload', feed_spec: true do
      assign(:google_trusted_store_setting, Spree::GoogleTrustedStoreSetting.create)
      render template: 'spree/admin/google_trusted_store_settings/edit'

      expect(rendered).to include 'shipment feed url'
    end

    it 'shows the url for cancelation automatic upload', feed_spec: true do
      assign(:google_trusted_store_setting, Spree::GoogleTrustedStoreSetting.create)
      render template: 'spree/admin/google_trusted_store_settings/edit'

      expect(rendered).to include 'cancelation feed url'
    end
  end
end