module Spree
  module Admin
    class GoogleProductsController < Spree::Admin::ResourceController
      def show
        redirect_to action: :edit
      end

      def edit
        @google_product = GoogleProduct.find(params[:id])
        render 'edit', locals: locals
      end

      def update
        @google_product = GoogleProduct.find(params[:id])

        @google_product.update_attributes permitted_params[:google_product]
        unless @google_product.valid?
          flash[:error] = @google_product.errors.full_messages.join(', ')
        end
        if params[:do_insert]
          response = @google_product.google_insert 

          if errors_in?(response)
            flash[:error] = 'Failed to upload to Google'
          else
            flash[:success] = 'Successfully uploaded to Google!'
          end
        end
        redirect_to action: 'edit'
      end

      private

      def errors_in?(response)
        begin
          !response.data.error['errors'].nil?
        rescue NoMethodError
          false
        end
      end

      def locals
        {
          google_product: @google_product,
          variant: @google_product.variant
        }
      end

      def permitted_params
        params.permit(:google_product).permit(
          *(@google_product.custom_attributes + %i(
            google_product_category
            automatically_update condition adult
          ))
        )
      end
    end
  end
end

