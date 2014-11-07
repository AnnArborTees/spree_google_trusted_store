require 'google/api_client'

module Spree
  Product.class_eval do
    def upload_to_google_shopping
      google_shopping.products.insert 'xxx', 'xxx'
    end

    protected



    def settings
      @gts_settings ||= GoogleTrustedStoreSetting.instance
    end

    def api_client
      @api_client ||= Google::APIClient.new
    end

    def google_shopping
      @google_shopping ||= api_client.discovered_api('content', 'v2')
    end

    def google_shopping_allowed?
      settings.use_google_shopping?
    end
  end
end
