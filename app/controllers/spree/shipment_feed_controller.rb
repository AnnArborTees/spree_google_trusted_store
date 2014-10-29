module Spree
  class ShipmentFeedController < ApplicationController
    include SpreeGoogleTrustedStore::OrderFeed

    def feed
      settings = Spree::GoogleTrustedStoreSetting.instance
      @orders = Order.complete.where("completed_at > ?",
                                     settings.last_feed_upload)

      if request.env['HTTP_USER_AGENT'] == 'googlebot'
        settings.update_attributes! last_feed_upload: Time.now
      end

      render text: process_orders(@orders)
    end
  end
end
