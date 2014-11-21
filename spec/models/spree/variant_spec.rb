require 'spec_helper'

describe Spree::Variant, variant_spec: true, story_161: true do
  it { is_expected.to have_one(:google_product) }

  describe '#should_update_google_product?' do
    context 'when there is a google_product present' do
      context 'and automatically_update? is true' do
        context 'and this is the master variant' do
          let(:variant) { create :master_variant }

          it 'returns true when product has no other variants' do
            expect(variant).to receive(:google_product)
              .and_return(double 'google product', automatically_update?: true)
              .twice
            expect(variant.should_update_google_product?).to be_truthy
          end

          it 'returns false when product has other variants' do
            expect(variant).to receive(:google_product)
              .and_return(double 'google product', automatically_update?: true)
              .twice
            expect(variant).to receive_message_chain(
              :product, :variants, :empty?
            )
              .and_return false

            expect(variant.should_update_google_product?).to_not be_truthy
          end
        end
      end

      context 'and automatically_update? is false' do
        let(:variant) { create :variant }

        it 'returns false' do
          expect(variant.should_update_google_product?).to_not be_truthy
        end
      end
    end
  end
end
