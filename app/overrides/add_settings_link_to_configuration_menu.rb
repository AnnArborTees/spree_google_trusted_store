Deface::Override.new(:virtual_path => "spree/admin/shared/_configuration_menu",
                     :name => "trusted_stores_settings",
                     :insert_bottom => "[data-hook='admin_configurations_sidebar_menu']",
                     :text => "<%= configurations_sidebar_menu_item 'Google Trusted Store', spree.edit_admin_google_trusted_store_setting_path(Spree::GoogleTrustedStoreSetting.instance) %>",
                     :disabled => false)

Deface::Override.new(:virtual_path => "spree/admin/shared/_configuration_menu",
                     :name => "google_stores_settings",
                     :insert_bottom => "[data-hook='admin_configurations_sidebar_menu']",
                     :text => "<%= configurations_sidebar_menu_item 'Google Shopping', spree.admin_google_shopping_settings_edit_path %>",
                     :disabled => false)
