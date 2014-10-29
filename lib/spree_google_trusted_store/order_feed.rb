module SpreeGoogleTrustedStore
  module OrderFeed
    ACCEPTED_CARRIER_CODES = %w(UPS FedEx USPS Other)
    ACCEPTED_OTHER_CARRIER_CODES = %w(
      ABFS AMWST BEKINS CNWY DHL ESTES HDUSA LASERSHIP MYFLWR ODFL RDAWAY
      TWW WATKINS YELL YRC OTHER
    )
    HEADERS = [
      'merchant order id',
      'tracking number',
      'carrier code',
      'other carrier name',
      'ship date'
    ]

    def process_orders(*args)
      orders = Array(args)

      options = { col_sep: "\t", headers: HEADERS, write_headers: true }

      CSV.generate(options) do |csv|
        orders.each do |order|
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

    protected

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