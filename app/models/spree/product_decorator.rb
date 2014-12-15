module Spree
  Product.class_eval do
    has_many :google_products, through: :variants

    after_save :update_google_products

    def update_google_products
      return unless Spree::GoogleShoppingSetting.instance.use_google_shopping?
      # TODO prepare a batch update or something...
      variants_including_master.each(&:update_google_product)
    end
  end
end
