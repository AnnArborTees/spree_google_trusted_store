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
      Class.new { extend Spree::GoogleShoppingResponses }
    end

    def upload_to_google(id_or_sku, options = {})
      error_handler   = options[:on_error]   || print_errors
      success_handler = options[:on_success] || print_success

      all_errors    = {}
      all_successes = []

      # This is conforming to my 'link' attribute hack, which requires
      # some kind of domain obviously. Check out the google_shopping.rb
      # initializer for more info.
      base_url = options[:base_url] || Spree::Store
        .default.first.domains.split(/\s/).first
      Thread.current[:response] = Struct.new(:original_uri).new(base_url)

      product = Spree::Product.where(id: id_or_sku).first ||
        Spree::Product
        .includes(:master)
        .where(spree_variants: {is_master: true, sku: id_or_sku})
        .first

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

    def upload_all_to_google(options = {})
      error_handler   = options[:on_error]   || print_errors
      success_handler = options[:on_success] || print_success

      all_errors    = {}
      all_successes = []

      t_shirt_category = Spree::ShippingCategory.where(name: 'T-shirt').first
      if t_shirt_category.nil?
        STDOUT.puts "Couldn't find T-shirt shipping category!"
        return
      end

      Spree::Variant
        .includes(:google_product)
        .where('spree_google_products.id is null')
        .references('spree_google_products')
        .includes(:product)
        .where(products: { shipping_category_id: t_shirt_category.id })
        .find_each do |variant|
          if variant.is_master?
            next unless variant.product.variants.empty?
          end

          upload_variant(variant) do |errors|
            if errors
              all_errors[variant] = errors
            else
              all_successes << variant
            end
          end
        end

      Spree::GoogleProduct
        .where(last_insertion_date: nil)
        .find_each do |google_product|
          upload_google_product(google_product) do |errors|
            if errors
              all_errors[google_product.variant] = errors
            else
              all_successes << google_product.variant
            end
          end
        end

      error_handler.call(all_errors)
      success_handler.call(all_successes)
    end
  end
end
