module Spree
  class GoogleFeedController < ApplicationController
    include SpreeGoogleTrustedStore::OrderFeed

    def shipment
      @orders = Order.complete.where("completed_at > ?", last(:shipment))
      update_feed_timestamp(:shipment) if is_google_bot?

      render text: process_orders(@orders)
    end

    def cancelation
      @orders = Order.where(state: 'canceled')
      
      update_feed_timestamp(:cancelation) if is_google_bot?

      render text: process_cancelations(@orders)
    end

    private

    def update_feed_timestamp(type)
      settings.update_attributes! "last_#{type}_upload" => Time.now
    end
    
    def last(type)
      settings.send("last_#{type}_upload")
    end

    def settings
      @settings ||= Spree::GoogleTrustedStoreSetting.instance
    end

    def is_google_bot?
      request.env['HTTP_USER_AGENT'] == 'googlebot'
    end
  end
end
