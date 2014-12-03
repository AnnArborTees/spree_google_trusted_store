Spree::Variant.class_eval do
  has_one :google_product, class_name: 'Spree::GoogleProduct'

  after_save :update_google_product
  before_destroy :delete_google_product
  after_create :make_sure_master_doesnt_have_google_product
  after_create :assign_google_product_attributes_from_masters

  def update_google_product
    google_product.google_insert if should_update_google_product?
  end

  def delete_google_product
    return unless use_google_shopping?
    return if google_product.nil?
    return unless google_product.has_product_id?

    google_product.google_delete
    google_product.destroy
  end

  def make_sure_master_doesnt_have_google_product
    return unless use_google_shopping?
    return unless product_id
    return if is_master?

    if product.master.google_product.try(:has_product_id?)
      product.master.google_product.google_delete
    end
  end

  def assign_google_product_attributes_from_masters
    return unless use_google_shopping?
    return unless product_id?
    return if is_master?

    master_product = product.master.google_product
    self.google_product = Spree::GoogleProduct.new
    return if master_product.nil?

    Spree::GoogleProduct::Attributes.instance.db_field_names.each do |field|
      google_product.send("#{field}=", master_product.send(field))
    end
    google_product.automatically_update = master_product.automatically_update
    google_product.save!
    save!
  end

  def should_update_google_product?
    google_product &&
    google_product.automatically_update? &&
    (is_master? ? product.variants.empty? : true)
  end

  def use_google_shopping?
    Spree::GoogleShoppingSetting.instance.use_google_shopping?
  end
end
