require 'spec_helper'

describe Spree::GoogleProduct, shopping_spec: true, story_161: true do
  it { is_expected.to belong_to :spree_product }

  it { is_expected.to have_db_column(:google_product_category).of_type(:string) }
  it { is_expected.to have_db_column(:condition).of_type(:string) }
  # TODO look into how this should handle product variants / master variant.
  it { is_expected.to have_db_column(:automatically_update).of_type(:boolean) }
  it { is_expected.to have_db_column(:adult).of_type(:boolean) }

  it { is_expected.to validate_inclusion_of(:google_product_category).in(Spree::GoogleProduct::ATTRIBUTES) }

  describe 'G_ATTRIBUTES' do
    it 'all attributes accepted by google products' do
      expect(Spree::GoogleProduct::G_ATTRIBUTES).to eq [
        :id, :title, :description, :google_product_category, :product_type,
        :link, :mobile_link, :image_link, :additional_image_link, :condition,

        :availability, :availability_date, :price, :sale_price,
        :sale_price_effective_date,

        :brand, :gtin, :mpn, :identifier_exists, :gender, :age_group,
        :size_type, :size_system,

        :color, :size,

        :material, :pattern, :item_group_id,

        :tax, :shipping, :shipping_weight, :shipping_label,

        :multipack, :is_bundle,

        :adult, :adwords_grouping, :adwords_labels, :adwords_redirect,

        :excluded_destination, :expiration_date
      ]
    end
  end

  describe '.configure' do
    it 'accepts a block, to which it passes a config object' do
      Spree::GoogleProduct.configure do |config|
        expect(config).to be_a Spree::GoogleProduct::Config
      end
    end
  end
end
