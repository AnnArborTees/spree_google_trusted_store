class CreateSpreeGoogleProducts < ActiveRecord::Migration
  def change
    create_table :spree_google_products do |t|
      t.string :google_product_category
      t.string :condition
      t.boolean :automatically_update
      t.boolean :adult
      t.integer :variant_id
      t.string :product_id

      t.timestamps
    end

    add_index :spree_google_products, :variant_id

    add_column :spree_google_shopping_settings, :google_api_appplication_name, :string
  end
end
