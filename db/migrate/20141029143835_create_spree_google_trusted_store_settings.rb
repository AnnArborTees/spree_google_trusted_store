class CreateSpreeGoogleTrustedStoreSettings < ActiveRecord::Migration
  def change
    create_table :spree_google_trusted_store_settings do |t|
      t.string :account_id
      t.string :default_locale
    end
  end
end
