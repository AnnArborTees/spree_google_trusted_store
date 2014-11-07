require 'spec_helper'

describe 'admin/google_shopping_settings/edit.html.erb', shopping_spec: true, story_161: true do
  def render!
    render template: 'spree/admin/google_shopping_settings/edit'
  end

  before(:each) do
    fake_routes = double('routes', edit_admin_general_settings_path: 'bogus',
                                   admin_google_shopping_setting_path: 'bogus')
    allow(view).to receive(:spree).and_return fake_routes
    allow(view).to receive(:current_spree_user).and_return nil
    assign(:google_shopping_setting, Spree::GoogleShoppingSetting.create)
  end

  it 'displays a text field for oauth2 keys and merchant id' do
    render!

    expect(rendered).to have_css 'input[type="text"][name="google_shopping_setting[merchant_id]"]'
    expect(rendered).to have_css 'input[type="text"][name="google_shopping_setting[oauth2_client_id]"]'
    expect(rendered).to have_css 'input[type="text"][name="google_shopping_setting[oauth2_client_secret]"]'
  end

  context 'when authenticated' do
    it 'displays "authenticated"' do
      allow_any_instance_of(Spree::GoogleShoppingSetting)
        .to receive(:authenticated?).and_return true

      render!

      expect(rendered).to have_content 'AUTHENTICATED'
    end

    context 'temporarily' do
      it 'displays "authenticated (temporarily)"' do
        allow_any_instance_of(Spree::GoogleShoppingSetting)
          .to receive(:authenticated?).and_return true
        allow_any_instance_of(Spree::GoogleShoppingSetting)
          .to receive(:temporarily_authenticated?).and_return true

        render!

        expect(rendered).to have_content 'AUTHENTICATED (TEMPORARILY)'
      end
    end
  end

  it 'displays a button for oauth2 authentication' do
    allow_any_instance_of(Spree::GoogleShoppingSetting)
      .to receive(:oauth2_client_id).and_return 'asdfid'
    allow_any_instance_of(Spree::GoogleShoppingSetting)
      .to receive(:oauth2_client_secret).and_return 'asdfsecret'
    
    render!
    expect(rendered).to have_css 'a', text: 'Authenticate'
  end
end