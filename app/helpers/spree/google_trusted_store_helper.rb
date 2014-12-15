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
      safely do
        settings = GoogleTrustedStoreSetting.instance
        render 'spree/google_trusted_store/badge', {
          id: settings.account_id,
          locale: settings.default_locale
        }
      end
    end

    def google_trusted_store_order_confirmation(order)
      safely do
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
    end

    def most_prominent_variant
      safely do
        local_assigns = try(:local_assigns) || {}

        local_assigns[:most_prominent_variant] ||
        local_assigns[:variant]                ||
        @most_prominent_variant                ||
        @variant                               ||
        @variants.try(:first)                  ||
        @product.try(:variants).try(:first)
      end
    end

    def most_prominent_variant_with_google_product
      safely do
        begin
          local_assigns = try(:local_assigns) || {}

          relation = @variants               ||
                     @product.try(:variants) ||
                     @products.try(:first).try(:variants)

          relation
            .includes(:google_product)
            .where.not(spree_google_products: { last_insertion_date: nil })
            .where(spree_google_products: { last_insertion_errors: '[]' } )
            .first
        rescue StandardError => e
          logger.error "Bang!: #{e.inspect}"
        end
      end
    end

    def valid_prominent_product
      safely do
        variant = most_prominent_variant
        return if variant.nil?
        google_product = variant.google_product
        if google_product.nil? || google_product.last_insertion_date.nil?
          variant = most_prominent_variant_with_google_product
          google_product = variant.google_product
        end
        return if google_product.nil?

        response = google_product.google_get
        return unless product?(response)
        response.data
      end
    end

    private

    def safely(default_return = nil, &block)
      raise 'plz pass block to me' unless block_given?

      begin
        yield
      rescue StandardError => e
        begin
          if GoogleErrorMailer.last_error_message != e.message
            GoogleErrorMailer.last_error_message = e.message
            GoogleErrorMailer.helper_error(e).deliver
          end
        rescue StandardError => e2
          logger.error "Failed to send error email!"
          logger.error e2.inspect
        end
        default_return
      end
    end

    def negative_adjustments_on(order)
      safely do
        value = order.all_adjustments.included.map(&:amount).reduce(0, :+)
        value <= 0 ? value : 0
      end
    end

    def digital_in?(order)
      false
    end

    def prodsearch_for(item)
      safely({}) do
        settings = Spree::GoogleShoppingSetting.instance
        return {} unless settings.use_google_shopping?

        google_product = item.variant.google_product
        return {} if google_product.nil?

        response       = google_product.google_get
        errors         = errors_from(response, false)

        return {} unless errors.empty?
        return {} unless product?(response)

        product = response.data

        {
          prodsearch_id:       product.id,
          prodsearch_store_id: settings.merchant_id,
          prodsearch_country:  product['country'] || 'US',
          prodsearch_language: product['language'] || 'en'
        }
      end
    end
  end
end
