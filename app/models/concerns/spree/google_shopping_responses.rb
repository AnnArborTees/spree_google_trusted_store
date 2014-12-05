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
      return if response.nil?

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

    def product_list?(response)
      begin
        response.data.is_a?(Google::APIClient::Schema::Content::V2::ProductsListResponse)
      rescue NameError
        false
      end
    end

    def settings
      @gts_settings ||= GoogleShoppingSetting.instance
    end

    def api_client
      @api_client ||= Google::APIClient.new(
          application_name: settings.google_api_application_name || 'Spree',
          generate_authenticated_request: :oauth_2,
          auto_refresh_token: true
        ).tap(&settings.method(:set_api_client_info))
    end

    def google_shopping
      @google_shopping ||= api_client.discovered_api('content', 'v2')
    end
 
    def refresh_if_unauthorized(after_method = nil)
      response = yield
      auth_error = bad_credential_errors_from(response)

      if auth_error
        if api_client.authorization.refresh_token
          if settings.update_from(api_client.authorization.refresh!)
            logger.info 'Got bad authorization from Google. Refreshing token...'
            response = yield
            if bad_credential_errors_from(response)
              logger.warn 'Still no dice on authentication!'
            end
          end
        else
          logger.warn("No refresh token; OAuth authentication required.")
        end
      end

      if after_method.is_a?(String) || after_method.is_a?(Symbol)
        send(after_method, response)
      elsif after_method.respond_to?(:call)
        after_method.call(response)
      end
      response
    end
  end
end
