module Spree
  module Admin
    class GoogleTrustedStoreSettingsController < Spree::Admin::ResourceController
      def show
        redirect_to action: :edit
      end
      def index
        redirect_to action: :edit, id: GoogleTrustedStoreSetting.instance
      end

      def edit
        @google_trusted_store_setting = GoogleTrustedStoreSetting.instance
      end
    end
  end
end
