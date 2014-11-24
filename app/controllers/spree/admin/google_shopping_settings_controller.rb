module Spree
  module Admin
    class GoogleShoppingSettingsController < Spree::Admin::ResourceController
      def update
        if params[:deauthenticate]
          settings = GoogleShoppingSetting.instance
          settings.current_access_token = nil
          settings.current_refresh_token = nil
          settings.current_expiration_date = nil
          settings.save!
          redirect_to spree.admin_google_shopping_settings_edit_path
        else
          super
        end
      end

      def show
        redirect_to spree.admin_google_shopping_settings_edit_path
      end
      def index
        redirect_to spree.admin_google_shopping_settings_edit_path
      end

      def edit
        @google_shopping_setting = GoogleShoppingSetting.instance
      end

      def oauth2
        if params[:error]
          return render text: "Oauth2 error: #{params[:error]}"
        end

        settings = GoogleShoppingSetting.instance

        case params[:state]
        when GoogleShoppingSetting.state_token
          if settings.process_authorization_code(params[:code])
            flash[:success] = "Successfully authenticated!"
          else
            flash[:error] = "Failed to authenticate"
          end
        else
          flash[:error] = "State token did not match. Perhaps try again."
        end

        GoogleShoppingSetting.scramble_state_token!
        
        redirect_to spree.admin_google_shopping_settings_edit_path
      end

      protected

      def collection_url
        spree.admin_google_shopping_settings_edit_url
      end
    end
  end
end
