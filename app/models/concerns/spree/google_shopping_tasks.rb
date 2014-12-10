module Spree
  module GoogleShoppingTasks
    def say_product_or_variant(variant)
      variant.is_master? ? 'product' : 'variant'
    end

    def print_errors
      proc do |variant_errors|
        variant_errors.each do |variant, errors|
          STDOUT.puts "****Errors on #{say_product_or_variant(variant)} #{variant.sku}: ****"
          errors.each(&STDOUT.method(:puts))
          STDOUT.puts "==========================================="
        end
      end
    end

    def print_success
      proc do |successes|
        successes.each do |variant|
          STDOUT.puts "****No errors on #{say_product_or_variant(variant)} #{variant.sku}****"
          STDOUT.puts "==========================================="
        end
      end
    end

    def email_errors
      proc do |variant_errors|
        Spree::GoogleErrorMailer.upload_task_error(variant_errors).deliver
      end
    end

    def do_nothing
      proc { |*_args| }
    end

    def google_utils
      @_google_utils ||= Class.new { extend Spree::GoogleShoppingResponses }
    end

    def upload_to_google(id_or_sku, options = {})
      error_handler   = options[:on_error]   || print_errors
      success_handler = options[:on_success] || print_success

      all_errors    = {}
      all_successes = []

      product = product_with_id_or_sku(id_or_sku)
      if product.nil?
        puts "Couldn't find a product with id or sku #{id_or_sku}"
        return
      end

      product.master.google_product ||= Spree::GoogleProduct.create

      master_product = product.master.google_product
      master_product.google_product_category = t_shirt_category
      master_product.save!

      if product.variants.any?
        product.variants.each do |variant|
          upload_variant(variant) do |errors|
            if errors
              all_errors[variant] = errors
            else
              all_successes << variant
            end
          end
        end

      else

        upload_google_product(master_product) do |errors|
          if errors
            all_errors[master_product.variant] = errors
          else
            all_successes << master_product.variant
          end
        end
      end

      error_handler.call(all_errors)
      success_handler.call(all_successes)
    end

    def t_shirt_category
      'Apparel & Accessories > Clothing > Shirts & Tops > T-Shirts'
    end

    def upload_google_product(google_product, options = {}, &block)
      category = options[:category] || t_shirt_category

      google_product.google_product_category = category
      google_product.automatically_update = true
      google_product.save!

      response = google_product.google_insert
      errors = google_utils.errors_from(response)
      yield errors
    end

    def upload_variant(variant, options = {}, &block)
      google_product = variant.google_product ||
        Spree::GoogleProduct.new(variant_id: variant.id)

      upload_google_product(google_product, options, &block)
    end

    def remove_from_google(id_or_sku)
      product = product_with_id_or_sku(id_or_sku)
      if product.nil?
        STDOUT.puts "Couldn't find a product with id or sku #{id_or_sku}"
        return
      end

      if product.variants.any?
        product.variants.each do |variant|
          google_product = variant.google_product
          next if google_product.nil?

          begin
            google_product.google_delete
            STDOUT.puts "Deleted google entry for #{variant.sku}"
          rescue StandardError => e
            STDOUT.puts "Error while deleting #{variant.sku}: #{e.message}"
          end
        end

      else
        master_product = product.master.google_product
        return if master_product.nil?

        begin
          master_product.google_delete
          STDOUT.puts "Deleted google entry for #{master_product}"
        rescue StandardError => e
          STDOUT.puts "Error while deleting #{product.master.sku}: #{e.message}"
        end
      end
    end

    def remove_dangling
      api_client      = google_utils.api_client
      google_shopping = google_utils.google_shopping
      settings        = google_utils.settings

      next_page_token = nil
      batch_entries   = []
      loop do
        response = google_utils.refresh_if_unauthorized do
          api_client.execute(
            api_method: google_shopping.products.list,
            parameters: {
              'merchantId' => settings.merchant_id,
              'fields'     => 'nextPageToken,resources(id,offerId,itemGroupId)',
              'maxResults' => 50
            }
              .merge(
                next_page_token ? { 'pageToken' => next_page_token } : {}
              )
          )
        end

        unless google_utils.product_list?(response)
          STDOUT.puts "Something went wrong when querying Google!"
          STDOUT.puts "Hopefully this isn't just response an empty response."
          return
        end

        STDOUT.puts "Processing #{response.data.resources.size} google product entires"

        dangling_entries = response.data.resources.reject do |entry|
          Spree::Variant.where(
            product_id: entry.item_group_id,
            sku:        entry.offer_id
          )
            .exists?
        end

        STDOUT.puts "Found #{dangling_entries.size} dangling"

        unless dangling_entries.empty?
          batch_entries += dangling_entries.map.with_index do |entry, index|
            {
              'batchId'    => index + batch_entries.size,
              'merchantId' => settings.merchant_id,
              'method'     => 'delete',
              'productId'  => entry.id
            }
          end
        end

        next_page_token = response.data.next_page_token
        STDOUT.puts "Next page token: #{next_page_token}"
        STDOUT.puts "==================================================="
        break if next_page_token.nil? || next_page_token.empty?
      end

      STDOUT.puts "Performing batch response to remove #{batch_entries.size} dangling products..."

      batch_response = google_utils.refresh_if_unauthorized do
        api_client.execute(
          api_method: google_shopping.products.custombatch,
          body_object: { 'entries' => batch_entries }
        )
      end

      batch_response.data.entries.each do |entry|
        # No idea which one of these is correct.
        errors = entry[:errors].try(:[], 'errors') || entry[:error].try(:[], 'errors')
        if errors
          errors.each do |error|
            STDOUT.puts %w(
              ERROR
              reason: #{error['reason']}
              message: #{error['message']}
            )
            STDOUT.puts "======================================="
          end
        end
      end

      STDOUT.puts "Done."
    end

    def insert_batch_entry(settings, google_product, batch_id)
      {
        'batchId'    => batch_id,
        'merchantId' => settings.merchant_id,
        'method'     => 'insert',
        'product'    => google_product.attributes_hash(true)
      }
    end

    def batch_insert(entries, error_handler = nil)
      response = google_utils.refresh_if_unauthorized do
        google_utils.api_client.execute(
          api_method: google_utils.google_shopping.products.custombatch,
          body_object: { 'entries' => entries }
        )
      end

      if error_handler
        all_errors = []

        response.data.entries.each do |entry|
          # No idea which one of these is correct.
          errors = entry[:errors].try(:[], 'errors') || entry[:error].try(:[], 'errors')
          all_errors += errors
        end

        error_handler.call(all_errors) if error_handler
      end

      response
    end

    def upload_all_to_google(options = {})
      error_handler             = options[:on_error]      || print_errors
      num_entries_until_request = options[:request_every] || 100

      t_shirt_category = Spree::ShippingCategory.where(name: 'T-shirt').first
      if t_shirt_category.nil?
        STDOUT.puts "Couldn't find T-shirt shipping category!"
        return
      end

      batch_entries = []

      check_batch_entries = lambda do
        if batch_entries.size >= num_entries_until_request
          batch_insert(batch_entries, error_handler)
          STDOUT.puts "Sent request with #{num_entries_until_request} products."
        end

        batch_entries.clear
      end

      Spree::Variant
        .includes(:google_product)
        .where('spree_google_products.id is null')
        .references('spree_google_products')
        .includes(:product)
        .where(spree_products: { shipping_category_id: t_shirt_category.id })
        .find_each do |variant|
          if variant.is_master?
            next unless variant.product.variants.empty?
          end

          batch_entries << insert_batch_entry(
            google_utils.settings,
            variant.google_product,
            batch_entries.size
          )

          check_batch_entries.call
        end

      Spree::GoogleProduct
        .where(last_insertion_date: nil)
        .find_each do |google_product|
          batch_entries << insert_batch_entry(
            google_utils.settings,
            google_product,
            batch_entries.size
          )

          check_batch_entries.call
        end

      unless batch_entries.empty?
        last_amount = batch_entries.size
        batch_insert(batch_entries, error_handler) 
        STDOUT.puts "Sent request with #{last_amount} products."
      end
    end

    private

    def product_with_id_or_sku(id_or_sku)
      Spree::Product.where(id: id_or_sku).first ||
        Spree::Product
          .includes(:master)
          .where(spree_variants: {is_master: true, sku: id_or_sku})
          .first
   end
  end
end
