module Spree
  module GoogleTrustedStoreHelper
    def order_fields
      %i(id domain email country currency total discounts shipping_total 
        tax_total est_ship_date est_delivery_date has_preorder has_digital)
    end

    def item_fields
      %i(item_name item_price item_quantity)
    end

    def google_trusted_store_badge
      settings = GoogleTrustedStoreSetting.instance
      render 'spree/google_trusted_store/badge', {
        id: settings.account_id,
        locale: settings.default_locale
      }
    end

    def google_trusted_store_order_confirmation(order)
      # use this:
      # URI.parse(request.original_url).host

      # render 'spree/google_trusted_store/order_confirmation', {
      #   id: 
      # }
    end
  end
end