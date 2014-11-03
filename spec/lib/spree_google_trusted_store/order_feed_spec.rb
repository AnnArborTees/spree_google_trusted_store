require 'spec_helper'

describe SpreeGoogleTrustedStore::OrderFeed, feed_spec: true, story_159: true do
  subject { Object.new.tap { |o| o.send(:extend, SpreeGoogleTrustedStore::OrderFeed) } }

  describe 'process_orders' do
    let!(:order) { create :shipped_order }

    it 'spits out a tab-delimited text file with the necessary attributes' do
      allow(order).to receive_message_chain(:shipments, :first, :tracking)
        .and_return 'UPS'

      result = subject.process_orders([order])

      expect(result).to include order.number + "\t"
      expect(result).to include "UPS\t"
      expect(result)
        .to include "\t" + 2.business_days.from_now.strftime('%F')
    end
  end

  describe 'process_cancelations', cancelation: true do
    let!(:canceled_order) { create :shipped_order }

    it 'spits outs a tab-delimited text file with the necessary attributes' do
      result = subject.process_cancelations([canceled_order])

      expect(result).to include canceled_order.number + "\t"
      expect(result).to include "MerchantCanceled" # TODO add cancelation reason to spree orders
    end
  end
end