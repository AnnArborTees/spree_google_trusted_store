Spree::Variant.class_eval do
  has_one :google_product, class_name: 'Spree::GoogleProduct'
end