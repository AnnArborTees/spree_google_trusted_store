require 'spec_helper'

describe 'Spree::GoogleShoppingTasks' do
  subject { Class.new { extend Spree::GoogleShoppingTasks } }
  let!(:product) { create :product }
  let!(:variant1) { create :variant, product: product }
  let!(:variant2) { create :variant, product: product }

  describe '#upload_to_google' do
    it 'calls google_insert on each variant' do
      google_product = double('GoogleProduct')
      allow(google_product).to receive(:google_product_category=)
      allow(google_product).to receive(:automatically_update=)
      allow(google_product).to receive(:save!)
      allow(google_product).to receive(:save)
      allow(google_product).to receive(:automatically_update?)
        .and_return false

      expect(google_product).to receive(:google_insert).twice

      allow_any_instance_of(Spree::Variant)
        .to receive(:google_product)
        .and_return google_product

      google_utils = double('google_utils')
      allow(google_utils).to receive(:errors_from)
        .and_return(dummy: 'hash')
      allow(subject).to receive(:google_utils)
        .and_return google_utils

      subject.upload_to_google(product.sku,
        base_url: 'http://test.com/',
        on_error: subject.do_nothing
      )
    end
  end

  # describe '#upload_all_to_google', testing: true do
    # it 'will work at some point (not an actual test case)' do
      # # variant1.google_product = Spree::GoogleProduct.new
# 
      # subject.upload_all_to_google()
    # end
  # end
end
