include Spree::Core::Engine.routes.url_helpers

Spree::GoogleProduct.configure do |config|
  # The following define id, title, and description fields to come
  # from the variant's name, sku, and description fields respectively.
  config.define.id(&:sku)
  config.define.title(&:name)
  config.define.description(&:description)
  
  # This defines the google_product_category field as a configurable
  # field of Spree::GoogleProduct.
  config.define.google_product_category.as_db_column
  
  # This grabs the url to the product the variant represents for the
  # link field.
  config.define.link do |variant|
    product_url(variant.product)
  end

  # NOTE: It is recommended you implement your own definition for
  # image_link and additional_image_link, so as to conform to 
  # Google's specifications:
  # https://support.google.com/merchants/answer/188494
  config.define.image_link do |variant|
    variant.images.first.try(:url)
  end
  config.define.image_link do |variant|
    variant.images[1..-1].map(&:url).to_json
  end

  config.define.condition.as_db_column

  # Availability will never change with this setting:
  config.define.availability 'in stock'

  # Remember, some fields must be structures.
  config.define.price do |variant|
    {
      value: variant.price,
      currency: variant.currency
    }
  end

  # TODO Look into whether or not master variant should be taken into
  # consideration here.
  config.define.item_group_id do |variant|
    variant.is_master? ? nil : variant.product_id
  end

  config.define.adult.as_db_column
end
