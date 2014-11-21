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

Deface::Override.new(virtual_path: 'spree/admin/variants/index',
                     name: 'variant_index_google_product_link_colgroup',
                     replace_contents: 'colgroup',
                     text: %(
                       <col style="width: 5%" />
                       <col style="width: 25%" />
                       <col style="width: 15%" />
                       <col style="width: 15%" />
                       <col style="width: 10%" />
                       <col style="width: 15%" />
                       <col style="width: 15%" />
                     ),
                     disabled: false)

Deface::Override.new(virtual_path: 'spree/admin/variants/index',
                     name: 'variant_index_google_product_link_th',
                     replace_contents: '[data-hook="variants_header"]',
                     text: %(
                       <tr>
                         <th colspan="2"><%= Spree.t(:options) %>
                         <th><%= Spree.t(:price) %></th>
                         <th><%= Spree.t(:sku) %></th>
                         <th><%= Google %></th>
                         <th class="actions"></th>
                       </tr>
                     ),
                     disabled: false)

Deface::Override.new(virtual_path: 'spree/admin/variants/index',
                     name: 'variant_index_google_product_link_td',
                     insert_before: 'td.actions',
                     text: %(
                       <td class="align-center"><%= link_to('Google Shopping', spree.admin_google_product_path(variant.google_product ||= Spree::GoogleProduct.new)) %></td>
                     ),
                     disabled: false)

Deface::Override.new(virtual_path: 'spree/admin/variants/edit',
                     name: 'variant_edit_google_link',
                     insert_before: '[data-hook="admin_variant_edit_form"]',
                     text: %(
                       <%= link_to 'Google Shopping', spree.admin_google_product_path(variant.google_product ||= Spree::GoogleProduct.new) %>
                     ),
                     disabled: false)

