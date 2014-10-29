module Spree
  module GoogleTrustedStoreHelper
    def order_fields
      %i(id domain email country currency total discounts shipping_total 
        tax_total est_ship_date est_delivery_date has_preorder has_digital)
    end

    def item_fields
      %i(item_name item_price item_quantity)
    end
  end
end