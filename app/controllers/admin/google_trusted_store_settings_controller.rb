module Admin
  class GoogleTrustedStoreSettingsController < Spree::Admin::BaseController
    def show
      redirect_to action: :edit
    end
    def index
      redirect_to action: :edit
    end
  end
end
