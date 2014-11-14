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

    def self.configure
      yield GoogleProduct::Attributes.configure
    end

    protected

    def attributes
      GoogleProduct::Attributes.instance
    end
  end
end
