# These settings are how we control how product variant data is sent
# to Google. It is recommended you look over all of these, and change
# most of them to fit your specific needs.
Spree::GoogleProduct.configure do |config|
  # The following define offer_id, title, and description fields to come
  # from the variant's name, sku, and description fields respectively.
  config.define.offer_id(&:sku)
  config.define.title(&:name)
  config.define.description(&:description)
  
  # This defines the google_product_category field as a configurable
  # field of Spree::GoogleProduct. If you add as_db_column defines,
  # you will need to create your own migrations to add the fields.
  # User added fields will be automatically added to the admin views
  # for Google Products.
  # 
  # Not passing a block will default to { |f, field| f.text_field(field.db_name) }
  config.define.google_product_category.as_db_column do |f|
    categories = Net::HTTP.get(
      URI 'http://www.google.com/basepages/producttype/taxonomy.en-US.txt'
    )
      .split("\n")[1..-1]

    f.collection_select(
      :google_product_category,
      categories, :to_s, :to_s,
      { include_blank: 'Valid Product Categories' },
      { class: 'select2-min-len-4' }
    )
  end
  
  # This grabs the url to the product the variant represents for the
  # link field. During an insert, the view/controller context is also
  # passed to these methods in order to provide access to url helpers.
  # It is an optional parameter, however, so make sure it's not nil
  # before using it.
  config.define.link do |variant, view|
    view.try(:product_variant_url, variant.product.slug, variant.id)
  end

  # NOTE: It is recommended you implement your own definition for
  # image_link and additional_image_link, so as to conform to 
  # Google's specifications:
  # https://support.google.com/merchants/answer/188494
  config.define.image_link do |variant|
    variant.images.first.try(:url) if variant.images
  end
  config.define.image_link do |variant|
    variant.images[1..-1].map(&:url).to_json if variant.images[1..-1]
  end

  config.define.condition.as_db_column(default: 'new') do |f|
    f.select :condition, %w(new used refurbished)
  end
  config.define.adult.as_db_column { |f| f.check_box(:adult) }

  # Availability will never change with this setting:
  config.define.availability 'in stock'

  config.define.channel 'online'
  config.define.content_language 'en'
  config.define.target_country 'US'

  # Struct fields can be defined as hashes.
  config.define.price do |variant|
    {
      value: variant.price.to_s,
      currency: variant.currency
    }
  end

  config.define.item_group_id do |variant|
    variant.is_master? ? nil : variant.product_id
  end

  # TODO add shipping fields!
end
