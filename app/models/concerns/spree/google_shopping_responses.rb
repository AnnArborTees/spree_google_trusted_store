module Spree
  module GoogleShoppingResponses
    def errors_from(response, json = true)
      errors = begin
        response.data.error['errors']
      rescue NoMethodError
        []
      end

      json ? errors.to_json : errors
    end

    def warnings_from(response)
      response.data.try(:warnings)
                   .try(:to_json)
    end

    def bad_credential_errors_from(response)
      begin
        response.data.error['errors'].find do |error|
          error['reason']  == 'authError' &&
          error['message'] == 'Invalid Credentials'
        end
      rescue NoMethodError
      end
    end

    def errors_in?(response)
      begin
        !(response.data.error['errors'].nil? ||
          response.data.error['errors'].empty?)
      rescue NoMethodError
        false
      end
    end

    def product?(response)
      begin
        response.data.is_a?(Google::APIClient::Schema::Content::V2::Product)
      rescue NameError
        false
      end
    end
  end
end
