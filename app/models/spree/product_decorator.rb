module Spree
  Product.class_eval do
    after_save :update_google_products

    def update_google_products
      variants_including_master.each(&:update_google_product)
    end
  end
end
