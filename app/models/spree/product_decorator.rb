module Spree
  Product.class_eval do
    after_save :update_google_products

    def update_google_products
      # TODO prepare a batch update or something...
      variants_including_master.each(&:update_google_product)
    end
  end
end
