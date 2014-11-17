require 'spec_helper'

describe Spree::GoogleProduct, shopping_spec: true, story_161: true do
  it { is_expected.to belong_to :variant }

  it { is_expected.to have_db_column(:google_product_category).of_type(:string) }
  it { is_expected.to have_db_column(:condition).of_type(:string) }
  # TODO look into how this should handle product variants / master variant.
  it { is_expected.to have_db_column(:automatically_update).of_type(:boolean) }
  it { is_expected.to have_db_column(:adult).of_type(:boolean) }
  it { is_expected.to have_db_column(:product_id).of_type(:string) }

  # it { is_expected.to validate_inclusion_of(:google_product_category) }

  let(:variant) { create :variant, google_product: Spree::GoogleProduct.new }
  let(:google_product) { variant.google_product }

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
        expect(config).to be_a Spree::GoogleProduct::Attributes
      end
    end
  end

  describe '#attributes_hash' do
    it 'collects all available attributes' do
      Spree::GoogleProduct.configure do |config|
        config.define.title 'test_title'
      end

      result = google_product.attributes_hash

      expect(result).to be_a Hash
      expect(result['title']).to eq 'test_title'
    end
  end

  describe '#attributes_json' do
    it 'transforms the hash keys into lowerCamelCase' do
      Spree::GoogleProduct.configure do |config|
        config.define.image_link 'test_img_link'
        config.define.additional_image_link ['test_additional']
      end

      result = google_product.attributes_json

      expect(result).to be_a String
      hash = JSON.parse(result)
      expect(hash.keys).to include 'imageLink'
      expect(hash.keys).to include 'additionalImageLinks'
    end
  end

  describe '#google_insert' do
    it 'executes the google api product insert method' do
      expect_any_instance_of(Google::APIClient).to receive(:execute)
        .with(hash_including(
            body_object: google_product.attributes_hash(true)
          ))

      google_product.google_insert
    end
  end

  describe '#google_get' do
    context 'when a product_id is present' do
      it 'executes the google api product get method' do
        allow(google_product).to receive(:product_id).and_return 'test123'
        expect_any_instance_of(Google::APIClient).to receive(:execute)
        .with(hash_including(
            parameters: hash_including('productId' => 'test123')
          ))

        google_product.google_get
      end
    end

    context 'when no product_id is present' do
      it 'returns nil' do
        expect(google_product.google_get).to be_nil
      end
    end
  end

  describe '#google_delete' do
    it 'executes google api product delete method' do
      allow(google_product).to receive(:product_id).and_return 'test123'
      expect_any_instance_of(Google::APIClient).to receive(:execute)
        .with(hash_including(
            parameters: hash_including('productId' => 'test123')
          ))

      google_product.google_delete
    end
  end

  describe '#merchant_center_link' do
    google_product.product_id = 'test:product:id'
    google_product.variant.sku = 'test'
    expect(google_product.merchant_center_link)
      .to eq 'https://google.com/merchants/view?merchantOfferId=test&channel=0&country=US&language=en'
  end

  describe '#status' do
    context 'when there is no product_id' do
      it 'returns "No associated product"' do
        google_product.product_id = nil
        expect(google_product.status).to eq 'No associated product'
      end
    end
    context 'when there is a product_id, and a valid google product' do
      it 'return "Valid"' do
        google_product.product_id = 'test:product:id'
        stub_response = double('Response',
          data: double('Data',
            title: 'test_title', id: 'test:product:id',
            error: {}
          )
        )
        expect_any_instance_of(Google::APIClient).to receive(:execute)
          .with(hash_including(
              parameters: hash_including('productId' => 'test:product:id')
            ))
          .and_return stub_response

        expect(google_product.status).to eq 'Valid'
      end
    end
    context 'when there is a product_id, and some warnings' do
      before(:each) do
        google_product.product_id = 'test:product:id'
        stub_response = double('Response',
          data: double('Data',
            title: 'test_title', id: 'test:product:id',
            warnings: [{
                'domain' => 'something',
                'reason' => 'test',
                'message' => 'test warning right here ladies and gentlemen'
              }]
          )
        )
        expect_any_instance_of(Google::APIClient).to receive(:execute)
          .with(hash_including(
              parameters: hash_including('productId' => 'test:product:id')
            ))
          .and_return stub_response
      end

      it 'returns "Valid with warnings"' do
        expect(google_product.status).to eq 'Valid with warnings'
      end

      it 'sets #warnings to the warnings from the response data' do
        google_product.status
        expect(google_product.warnings).to eq [{
            'domain' => 'something',
            'reason' => 'test',
            'message' => 'test warning right here ladies and gentlemen'
          }]
      end
    end
    context 'when there is a product_id, but no google product' do
      it 'sets product_id to nil and returns "No associated product"' do
        google_product.product_id = 'test:product:id'

        google_product.product_id = 'test:product:id'
        stub_response = double('Response',
          data: double('Data',
            error: { 'errors' => [{'reason' => 'invalid'}] }
          )
        )
        expect_any_instance_of(Google::APIClient).to receive(:execute)
          .with(hash_including(
              parameters: hash_including('productId' => 'test:product:id')
            ))
          .and_return stub_response
      end
    end
  end
end
