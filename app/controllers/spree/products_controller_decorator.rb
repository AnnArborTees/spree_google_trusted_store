module Spree
  ProductsController.class_eval do
    alias_method :original_show, :show
    def show
      return unless @product
      original_show
      return unless params[:variant_id]

      @variant = Spree::Variant.find(params[:variant_id])
      @variant = nil if @variant.product_id != @product.id
    end
  end
end
