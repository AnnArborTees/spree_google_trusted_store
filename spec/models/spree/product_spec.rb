require 'spec_helper'

describe Spree::Product, product_spec: true, story_161: true do
  context 'when gts settings allow google shopping' do
    
    describe '#upload_to_google_shopping' do
      it 'inserts product data into google shopping using google api'

      it 'invalidates the product when there is trouble using google api'
    end

    describe '#remove_from_google_shopping' do
      it 'removes the product from google shopping'
    end

    describe '#get_google_shopping_info' do
      it "returns the google api object for this product's google shopping entry"
    end

  end
end