module Spree
  module GoogleTrustedStoreHelper
    include GoogleShoppingResponses

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
      render 'spree/google_trusted_store/order_confirmation', {
        id:             order.number,
        domain:         URI.parse(request.original_url).host,
        email:          order.email,
        country:        order.shipping_address.try(:iso) || 'US',
        currency:       order.currency,
        total:          order.total,
        discounts:      negative_adjustments_on(order),
        shipping_total: order.shipment_total,
        tax_total:      order.included_tax_total,
        est_ship_date:  2.business_days.from_now.strftime('%F'),
        has_preorder:   order.backordered? ? 'Y' : 'N',
        has_digital:    digital_in?(order) ? 'Y' : 'N',

        items: order.line_items.map do |item|
          {
            name:     item.name,
            price:    item.price,
            quantity: item.quantity
          }
            .merge(prodsearch_for(item))
        end
      }
    end

    def most_prominent_variant
      local_assigns = try(:local_assigns) || {}

      local_assigns[:most_prominent_variant] ||
      local_assigns[:variant]                ||
      @variant                               ||
      @variants.try(:first)
    end

    def valid_prominent_product
      variant = most_prominent_variant
      return if variant.nil?
      google_product = variant.google_product

      response = google_product.google_get
      return unless product?(response)
      response.data
    end

    private

    def negative_adjustments_on(order)
      value = order.all_adjustments.included.map(&:amount).reduce(0, :+)
      value <= 0 ? value : 0
    end

    def digital_in?(order)
      false
    end

    def prodsearch_for(item)
      settings = Spree::GoogleShoppingSetting.instance
      return {} unless settings.use_google_shopping?

      google_product = item.variant.google_product
      response       = google_product.google_get
      errors         = errors_from(response, false)

      return {} unless errors.empty?
      return {} unless product?(response)

      product = response.data
      {
        prodsearch_id:       product.id,
        prodsearch_store_id: settings.merchant_id,
        prodsearch_country:  product.country,
        prodsearch_language: product.language
      }
    end
  end
end
