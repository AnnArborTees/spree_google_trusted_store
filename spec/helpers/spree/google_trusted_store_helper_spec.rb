require 'spec_helper'

describe Spree::GoogleTrustedStoreHelper, helper_spec: true, story_159: true do
  describe '#google_trusted_store_badge' do
    it 'renders spree/google_trusted_store/badge partial', badge: true do
      expect(helper)
        .to receive(:render)
        .with('spree/google_trusted_store/badge', anything)

      helper.google_trusted_store_badge
    end

    it 'passes info based on GoogleTrustedStoreSettings.account_id/default_locale' do
      settings = double('Google Trusted Store Settings',
        account_id: '123987',
        default_locale: 'en_US'
      )
      expect(Spree::GoogleTrustedStoreSetting)
        .to receive(:instance)
        .and_return settings

      expect(helper)
        .to receive(:render)
        .with(anything, hash_including(id: '123987', locale: 'en_US'))

      helper.google_trusted_store_badge
    end
  end

  describe '#google_trusted_store_order_confirmation' do
    let(:order) { create :order_ready_to_ship, ship_address: create(:address) }

    it 'renders spree/google_trusted_store/order_confirmation partial' do
      expect(helper)
        .to receive(:render)
        .with('spree/google_trusted_store/order_confirmation', anything)

      helper.google_trusted_store_order_confirmation(create :order)
    end

    it 'assigns locals based on a passed Order object', locals: true do
      expect(helper).to receive_message_chain(:request, :original_url)
        .and_return 'http://www.test.com/order/complete'

      expected_locals = {
        id:             order.number,
        domain:         'www.test.com',
        email:          order.email,
        country:        order.shipping_address.country.iso,
        currency:       order.currency,
        total:          order.total,
        discounts:      order.shipping_discount,  # TODO confirm this is the only source of discounts
        shipping_total: order.shipment_total,
        tax_total:      order.included_tax_total,
        est_ship_date:  2.business_days.from_now.strftime('%F'),
        has_preorder:   order.backordered? ? 'Y' : 'N',
        has_digital:    'N',

        items: order.line_items.map do |item|
          {
            name:     item.name,
            price:    item.price,
            quantity: item.quantity
          }
        end
      }

      expect(helper)
        .to receive(:render)
        .with(anything, expected_locals)

      helper.google_trusted_store_order_confirmation(order)
    end

    context 'with a valid google product' do
      let!(:dummy_response_data) do
        Struct.new(:id, :country, :language)
          .new('test:product:id', 'US', 'en')
      end

      let!(:dummy_response) do
        double('google_get response', data: dummy_response_data)
      end

      it 'assigns prodsearch id, store_id, country and language' do
        allow(helper).to receive_message_chain(:request, :original_url)
          .and_return 'http://www.test.com/order/complete'

        line_item = order.line_items.first
        allow(order).to receive(:line_items).and_return [line_item]

        variant = line_item.variant
        allow(line_item).to receive(:variant).and_return variant

        product = double('google_product', google_get: dummy_response)
        allow(variant).to receive(:google_product).and_return product

        allow(Spree::GoogleShoppingSetting).to receive(:instance)
          .and_return double('google shopping settings',
                             merchant_id: '111333',
                             use_google_shopping?: true)

        allow(helper).to receive(:errors_from).and_return []
        allow(helper).to receive(:product?).and_return true

        items_hash = {
          items: [{
            name: line_item.name,
            price: line_item.price,
            quantity: line_item.quantity,

            prodsearch_id: 'test:product:id',
            prodsearch_store_id: '111333',
            prodsearch_country: 'US',
            prodsearch_language: 'en'
          }]
        }

        expect(helper)
          .to receive(:render)
          .with(anything, hash_including(items_hash))

          helper.google_trusted_store_order_confirmation(order)
      end
    end
  end
end

