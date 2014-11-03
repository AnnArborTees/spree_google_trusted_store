module SpreeGoogleTrustedStore
  module OrderFeed
    ACCEPTED_CARRIER_CODES = %w(UPS FedEx USPS Other)
    ACCEPTED_OTHER_CARRIER_CODES = %w(
      ABFS AMWST BEKINS CNWY DHL ESTES HDUSA LASERSHIP MYFLWR ODFL RDAWAY
      TWW WATKINS YELL YRC OTHER
    )
    ACCEPTED_CANCELATION_REASONS = %w(
      BuyerCanceled MerchantCanceled DuplicateInvalid FraudFake
    )
    SHIPMENT_HEADERS = [
      'merchant order id',
      'tracking number',
      'carrier code',
      'other carrier name',
      'ship date'
    ]
    CANCELATION_HEADERS = [
      'merchant order id',
      'reason'
    ]

    def process_orders(orders)
      CSV.generate(options_for SHIPMENT_HEADERS) do |csv|
        orders.send(each_method(orders)) do |order|
          csv << [
            merchant_order_id(order),
            tracking_number(order),
            carrier_code(order),
            other_carrier_name(order),
            ship_date(order)
          ]
        end
      end
    end

    def process_cancelations(orders)
      CSV.generate(options_for SHIPMENT_HEADERS) do |csv|
        orders.send(each_method(orders)) do |order|
          csv << [
            merchant_order_id(order),
            'MerchantCanceled' # TODO add cancelation reason to spree order model
          ]
        end
      end
    end

    protected

    def options_for(headers)
      { col_sep: "\t", headers: headers, write_headers: true }
    end

    def each_method(list)
      list.respond_to?(:find_each) ? :find_each : :each
    end

    def merchant_order_id(order)
      order.number
    end

    def tracking_number(order)
      '' # TODO how to get this?
    end

    def carrier_code(order)
      if ACCEPTED_CARRIER_CODES.include? tracking_of(order)
        tracking_of(order)
      else
        'Other'
      end
    end

    def other_carrier_name(order)
      if ACCEPTED_OTHER_CARRIER_CODES.include? tracking_of(order)
        tracking_of(order)
      else
        'OTHER'
      end
    end

    def ship_date(order)
      2.business_days.after(order.completed_at).strftime('%F')
    end

    private

    def tracking_of(order)
      # TODO assumes all shipments have the same tracking
      order.shipments.first.try(:tracking) || 'Other'
    end
  end
end