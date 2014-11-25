class AddCurrentHostToSpreeGoogleShoppingSettings < ActiveRecord::Migration
  def change
    add_column :spree_google_shopping_settings, :current_host, :string
    rename_column :spree_google_shopping_settings, :google_api_appplication_name, :google_api_application_name
  end
end
