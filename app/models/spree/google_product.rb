module Spree
  class GoogleProduct < ActiveRecord::Base
    G_ATTRIBUTES = [
      :id, :title, :description, :google_product_category, :product_type,
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

      :excluded_destination, :expiration_date
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

    private

    def camelize(key, value)
      (value.is_a?(Array) ? key.pluralize : key)
        .camelize(:lower)
    end
  end
end
