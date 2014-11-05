require 'spec_helper'

describe 'admin/google_shopping_settings/edit.html.erb', shopping_spec: true, story_161: true do
  it 'displays a text field for oauth2 keys and merchant id' do
    assign(:google_shopping_setting, Spree::GoogleShoppingSetting.create)
    render template: 'spree/admin/google_shopping_settings/edit'

    expect(rendered).to have_css 'input[type="text"][name="google_shopping_setting[merchant_id]"]'
    expect(rendered).to have_css 'input[type="text"][name="google_shopping_setting[oauth2_client_id]"]'
    expect(rendered).to have_css 'input[type="text"][name="google_shopping_setting[oauth2_client_secret]"]'
  end
end