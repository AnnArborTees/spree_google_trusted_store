Deface::Override.new(:virtual_path => "spree/admin/shared/_configuration_menu",
                     :name => "mockbot_ideas_admin_configurations_menu",
                     :insert_bottom => "[data-hook='admin_configurations_sidebar_menu']",
                     :text => "<%= configurations_sidebar_menu_item 'Google Trusted Store', spree.admin_spree_google_trusted_store_settings_path %>",
                     :disabled => false)
