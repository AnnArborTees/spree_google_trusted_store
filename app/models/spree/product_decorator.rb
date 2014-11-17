require 'google/api_client'

module Spree
  Product.class_eval do
    def update_google
      raise 'TODO do stuff based on how many variants are present...'
    end
  end
end
