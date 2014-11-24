class CreateSpreeGoogleShoppingSettings < ActiveRecord::Migration
  def change
    create_table :spree_google_shopping_settings do |t|
      t.string :merchant_id
      t.string :oauth2_client_id
      t.string :oauth2_client_secret
      t.string :current_access_token
      t.string :current_refresh_token
      t.datetime :current_expiration_date
      t.boolean :use_google_shopping

      t.timestamps
    end
  end
end
