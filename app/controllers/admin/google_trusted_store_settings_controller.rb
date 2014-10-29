module Admin
  class GoogleTrustedStoreSettingsController < Spree::Admin::BaseController
    def show
      redirect_to action: :edit
    end
    def index
      redirect_to action: :edit
    end

    def edit
      @google_trusted_store_setting = GoogleTrustedStoreSetting.instance
    end
  end
end
