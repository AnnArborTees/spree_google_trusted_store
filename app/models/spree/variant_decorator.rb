Spree::Variant.class_eval do
  has_one :google_product, class_name: 'Spree::GoogleProduct'

  after_save :update_google_product
  before_destroy :delete_google_product
  after_create :make_sure_master_doesnt_have_google_product

  def update_google_product
    google_product.google_insert if should_update_google_product?
  end

  def delete_google_product
    return unless google_product.has_product_id?

    google_product.google_delete
    google_product.destroy
  end

  def make_sure_master_doesnt_have_google_product
    return unless product_id
    return if is_master?

    if product.master.google_product.try(:has_product_id?)
      product.master.google_product.google_delete
    end
  end

  def should_update_google_product?
    google_product &&
    google_product.automatically_update? &&
    (is_master? ? product.variants.empty? : true)
  end
end