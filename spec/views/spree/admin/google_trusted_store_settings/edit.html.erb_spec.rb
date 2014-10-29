require 'spec_helper'

describe 'spree/admin/google_trusted_store_settings/edit.html.erb', settings_spec: true, story_159: true do
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

      expect(rendered).to include spree.google_trusted_store_shipment_feed_url
    end
  end
end