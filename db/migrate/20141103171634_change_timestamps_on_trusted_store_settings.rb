class ChangeTimestampsOnTrustedStoreSettings < ActiveRecord::Migration
  def change
    change_table :spree_google_trusted_store_settings do |t|
      t.remove :last_feed_upload
      t.datetime :last_shipment_upload
      t.datetime :last_cancelation_upload
    end
  end
end
