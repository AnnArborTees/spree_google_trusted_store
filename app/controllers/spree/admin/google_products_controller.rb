module Spree
  module Admin
    class GoogleProductsController < Spree::Admin::ResourceController
      include GoogleShoppingResponses

      def show
        redirect_to action: :edit
      end

      def edit
        @google_product = GoogleProduct.find(params[:id])
        render 'edit', locals: locals
      end

      def update
        @google_product = GoogleProduct.find(params[:id])

        finish = -> { redirect_to action: 'edit' }

        if !params[:do_delete] && update_google_product!
          update_flash :success, "Successfully updated local properties."
        else
          update_flash :error, @google_product.errors.full_messages.join(', ')
          finish = -> { render 'edit', locals: locals }
        end

        if params[:do_insert] && params[:do_insert].include?('Upload')
          google(:insert, 'upload to Google', self)
        elsif params[:do_delete]
          google(:delete, 'remove from Google')
        end

        if params[:all_variants]
          if update_google_product_children!
            update_flash :success, "Updated all variants"
          else
            update_flash :error, "Couldn't update all variants"
            finish = -> { render 'edit', locals: locals }
          end
        end
        
        finish.call
      end

      private

      def google(method, verb, *args)
        response = @google_product.send("google_#{method}", *args)

        if errors_in?(response)
          update_flash :error, "Failed to #{verb}."
        else
          update_flash :success, "Successfully #{verb}!"
        end
      end

      def update_google_product!
        @google_product.update_attributes permitted_params[:google_product]
      end

      def update_google_product_children!
        # TODO maybe collect errors

        master = @google_product.variant
        return false unless master.is_master?

        result = true

        master.product.variants.each do |variant|
          google_product = variant.google_product ||
            Spree::GoogleProduct.new(variant_id: variant.id)

          result = result &&
            google_product.update_attributes(permitted_params[:google_product])

          variant.save
        end

        result
      end

      def update_flash(key, value)
        if key == :success && flash_okay?(:error)
          flash[:error] = "(Error) #{flash[:error]} ; (Success) #{value}"
        elsif key == :error && flash_okay?(:success)
          success = flash[:success]
          flash[:success] = nil
          flash[:error] = "(Error) #{value}; (Success) #{success}"
        elsif flash_okay?(key)
          flash[key] += ", #{value}"
        else
          flash[key] = value
        end
      end

      def flash_okay?(key)
        return false if flash[key].nil?
        return false if flash[key].empty?
        return true
      end

      def locals
        {
          google_product: @google_product,
          variant: @google_product.variant
        }
      end

      def permitted_params
        params.permit(
          :do_insert, :do_delete,
          google_product: Spree::GoogleProduct::Attributes.instance
            .db_field_names + %i(
              automatically_update
            )
        )
      end
    end
  end
end

