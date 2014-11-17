module Spree
  class GoogleProduct < ActiveRecord::Base
    G_ATTRIBUTES = [
      :offer_id, :title, :description, :google_product_category, :product_type,
      :link, :mobile_link, :image_link, :additional_image_link, :condition,

      :availability, :availability_date, :price, :sale_price,
      :sale_price_effective_date,

      :brand, :gtin, :mpn, :identifier_exists, :gender, :age_group,
      :size_type, :size_system,

      :color, :size,

      :material, :pattern, :item_group_id,

      :tax, :shipping, :shipping_weight, :shipping_label,

      :multipack, :is_bundle,

      :adult, :adwords_grouping, :adwords_labels, :adwords_redirect,

      :excluded_destination, :expiration_date,

      :content_language, :target_country
    ]

    belongs_to :variant, class_name: 'Spree::Variant'

    def self.configure
      yield GoogleProduct::Attributes.instance
    end

    def attributes_hash(camelize_keys = false)
      G_ATTRIBUTES.map do |attribute|
        value = Attributes.instance.value_of(variant, attribute)
        next if value.nil?
        key = camelize_keys ? camelize(attribute.to_s, value) : attribute
        next key, value
      end
        .compact
        .to_h
        .with_indifferent_access
    end

    def attributes_json
      attributes_hash(true).to_json
    end

    def status
      raise 'implement me plz'
    end

    def google_get
      return nil unless has_product_id?

      api_client.execute(
        api_method: google_shopping.products.get,
        parameters: {
          'merchantId' => settings.merchant_id,
          'productId' => product_id
        }
      )
    end

    def google_insert
      api_client.execute(
        api_method: google_shopping.products.insert,
        parameters: { 'merchantId' => settings.merchant_id },
        body_object: attributes_hash(true)
      )
    end

    def google_delete
      return nil unless has_product_id?

      api_client.execute(
        api_method: google_shopping.products.delete,
        parameters: {
          'merchantId' => settings.merchant_id,
          'productId' => product_id
        }
      )
    end

    def has_product_id?
      !(product_id.nil? || product_id.empty?)
    end

    protected

    def settings
      @gts_settings ||= GoogleShoppingSetting.instance
    end

    def api_client
      @api_client ||= Google::APIClient.new(
          application_name: settings.google_api_appplication_name || 'Spree',
          generate_authenticated_request: :oauth_2,
          auto_refresh_token: true
        ).tap(&settings.method(:set_api_client_info))
    end

    def google_shopping
      @google_shopping ||= api_client.discovered_api('content', 'v2')
    end

    def camelize(key, value)
      (value.is_a?(Array) ? key.pluralize : key)
        .camelize(:lower)
    end
  end
end
