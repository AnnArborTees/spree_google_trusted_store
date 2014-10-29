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
      byebug
      render 'spree/google_trusted_store/order_confirmation', {
        id:             order.number,
        domain:         URI.parse(request.original_url).host,
        email:          order.email,
        country:        order.shipping_address.try(:iso_name) || 'en_US',
        currency:       order.currency,
        total:          order.total,
        discounts:      order.shipping_discount,
        shipping_total: order.shipment_total,
        tax_total:      order.included_tax_total,
        est_ship_date:  'TODO what to put here',
        has_preorder:   order.backordered? ? 'Y' : 'N',
        has_digital:    'N',

        items: order.line_items.map do |item|
          {
            name:     item.name,
            price:    item.price,
            quantity: item.quantity
          }
        end
      }
    end
  end
end