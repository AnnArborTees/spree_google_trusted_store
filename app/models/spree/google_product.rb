require 'google/api_client'

module Spree
  class GoogleProduct < ActiveRecord::Base
    include GoogleShoppingResponses

    G_ATTRIBUTES = [
      :offer_id, :title, :description, :google_product_category, :product_type,
      :link, :mobile_link, :image_link, :additional_image_link, :condition,

      :availability, :availability_date, :price, :sale_price,
      :sale_price_effective_date,

      :brand, :gtin, :mpn, :identifier_exists, :gender, :age_group,
      :size_type, :size_system,

      :color, :size, :sizes,

      :material, :pattern, :item_group_id,

      :tax, :shipping, :shipping_weight, :shipping_label,

      :multipack, :is_bundle,

      :adult, :adwords_grouping, :adwords_labels, :adwords_redirect,

      :excluded_destination, :expiration_date,

      :content_language, :target_country, :channel
    ]

    belongs_to :variant, class_name: 'Spree::Variant'

    def self.configure(&block)
      yield GoogleProduct::Attributes.instance
    end

    def self.custom_fields
      column_names - %w(
        google_product_category adult automatically_update
        product_id last_insertion_date last_insertion_errors
        last_insertion_warnings variant_id id variant
      )
    end

    def attributes_hash(camelize_keys = false, context = nil)
      variant.reload
      G_ATTRIBUTES.map do |attribute|
        value = Attributes.instance.value_of(variant, attribute, context)
        next if value.nil?
        key = camelize_keys ? camelize(attribute.to_s) : attribute
        next key, value
      end
        .compact
        .to_h
        .with_indifferent_access
    end

    def attributes_json
      attributes_hash(true).to_json
    end

    # TODO unused, I think
    def custom_attributes
      self.class.column_names - [
        :last_insertion_date, :last_insertion_errors,
        :last_insertion_warnings, :product_id,
        :automatically_update, :condition, :adult,
        :google_product_category, :updated_at,
        :created_at
      ]
    end

    def friendly_last_insert_date
      last_insertion_date.strftime('%b %d, %Y; %r')
    end

    def format(func)
      data = JSON.parse send(func)
      data.map do |datum|
        {
          reason: datum['reason'].underscore.humanize,
          message: datum['message']
        }
      end
    end

    def google_get
      return unless has_product_id?

      refresh_if_unauthorized do
        api_client.execute(
          api_method: google_shopping.products.get,
          parameters: {
            'merchantId' => settings.merchant_id,
            'productId' => product_id
          }
        )
      end
    end

    def google_insert(context)
      refresh_if_unauthorized(:after_insert) do
        api_client.execute(
          api_method: google_shopping.products.insert,
          parameters: { 'merchantId' => settings.merchant_id },
          body_object: attributes_hash(true, context)
        )
      end
    end

    def google_delete
      return unless has_product_id?

      refresh_if_unauthorized(:after_delete) do
        api_client.execute(
          api_method: google_shopping.products.delete,
          parameters: {
            'merchantId' => settings.merchant_id,
            'productId' => product_id
          }
        )
      end
    end

    def has_product_id?
      !(product_id.nil? || product_id.empty?)
    end

    def merchant_center_link
      return unless has_product_id?

      # TODO This should maybe not be hardcoded for
      # channel&country&language?
      "https://www.google.com/merchants/view?"\
      "merchantOfferId=#{variant.sku}&channel=0&country=US&language=en"
    end

    protected

    def refresh_if_unauthorized(after_method = nil)
      response = yield
      auth_error = bad_credential_errors_from(response)

      if auth_error
        if api_client.authorization.refresh_token
          if settings.update_from(api_client.authorization.refresh!)
            logger.info 'Got bad authorization from Google. Refreshing token...'
            response = yield
            if bad_credential_errors_from(response)
              logger.warn 'Still no dice on authentication!'
            end
          end
        else
          logger.warn("No refresh token; OAuth authentication required.")
        end
      end

      send(after_method, response) if after_method
      self.product_id = response.data.id if product?(response)
      save!
      response
    end

    def after_insert(response)
      self.last_insertion_errors   = errors_from(response)
      self.last_insertion_warnings = warnings_from(response)
      self.last_insertion_date     = Time.now
    end

    def after_delete(response)
      self.product_id = nil
      self.last_insertion_warnings = nil
      self.last_insertion_errors = nil
    end

    def settings
      @gts_settings ||= GoogleShoppingSetting.instance
    end

    def api_client
      @api_client ||= Google::APIClient.new(
          application_name: settings.google_api_application_name || 'Spree',
          generate_authenticated_request: :oauth_2,
          auto_refresh_token: true
        ).tap(&settings.method(:set_api_client_info))
    end

    def google_shopping
      @google_shopping ||= api_client.discovered_api('content', 'v2')
    end

    def camelize(key)
      case key
      when 'additional_image_link' then 'additionalImageLinks'
      else key.camelize(:lower)
      end
    end
  end
end
