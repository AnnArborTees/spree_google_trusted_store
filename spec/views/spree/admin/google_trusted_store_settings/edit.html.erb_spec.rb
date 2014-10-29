require 'spec_helper'

describe 'spree/admin/google_trusted_store_settings/edit.html.erb', settings_spec: true, story_159: true do
  it 'displays a text field for account_id and default_locale' do
    assign(:google_trusted_store_setting, Spree::GoogleTrustedStoreSetting.create)
    render 'spree/admin/google_trusted_store_settings/edit'

    expect(rendered).to have_css 'input[type="text"][name="google_trusted_store_setting[account_id]"]'
    expect(rendered).to have_css 'input[type="text"][name="google_trusted_store_setting[default_locale]"]'
  end
end