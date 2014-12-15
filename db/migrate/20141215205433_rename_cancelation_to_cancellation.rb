class RenameCancelationToCancellation < ActiveRecord::Migration
  def change
    rename_column :spree_google_trusted_store_settings,
                  :last_cancelation_upload, :last_cancellation_upload
  end
end
