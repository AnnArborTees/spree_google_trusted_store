module Spree
  class GoogleFeedController < ApplicationController
    include SpreeGoogleTrustedStore::OrderFeed

    def shipment
      if settings.last_shipment_upload.nil?
        settings.last_shipment_upload = Time.now
        settings.save
      end
      @orders = Order.complete.where("completed_at > ?", last(:shipment)).to_a

      update_feed_timestamp_after(60, :shipment) if is_google_bot?

      respond_to do |format|
        format.text { render inline: process_orders(@orders) }
      end
    end

    def cancellation
      if settings.last_cancellation_upload.nil?
        settings.last_cancellation_upload = Time.now
        settings.save
      end
      @orders = Order.where(state: 'canceled')
                     .where("updated_at > ?", last(:cancellation)).to_a
      
      update_feed_timestamp_after(60, :cancellation) if is_google_bot?

      respond_to do |format|
        format.text { render inline: process_cancellations(@orders) }
      end
    end

    private

    def update_feed_timestamp_after(time, type)
      Thread.new(time, type, Time.now) do |sleep_for, feed_type, set_to|
        sleep sleep_for
        s = Spree::GoogleTrustedStoreSetting.instance
        s.update_attributes! "last_#{feed_type}_upload" => set_to
      end
    end

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
      case (request.env['HTTP_USER_AGENT'] || '').downcase.strip
      when 'google-bot', 'google-xrawler' then true
      else false
      end
    end
  end
end
