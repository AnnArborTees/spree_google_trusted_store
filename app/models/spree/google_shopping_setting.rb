module Spree
  class GoogleShoppingSetting < ActiveRecord::Base
    class Error < StandardError
    end

    include Spree::Core::Engine.routes.url_helpers
    default_url_options[:host] = 'http://test.com' # TODO CHANGE TO ACTUAL URL SOMEHOW

    ENDPOINT = 'https://accounts.google.com'
    ENDPOINT_PATH = '/o/oauth2/token'
    AUTHENTICATION = 'https://accounts.google.com/o/oauth2/auth'
    SCOPE = 'https://www.googleapis.com/auth/content'

    class << self
      attr_accessor :state_token

      def instance(api_client = nil)
        first or create
      end

      def create
        all.exists? ? first : super
      end

      def scramble_state_token!
        self.state_token = SecureRandom.urlsafe_base64
      end
    end

    def admin_oauth2_callback_url
      self.class.default_url_options[:host] = current_host || 'http://test.com'
      super
    end

    def set_auth_info(auth)
      auth.redirect_uri  = admin_oauth2_callback_url
      auth.expires_in    = expires_in
      auth.client_id     = oauth2_client_id
      auth.client_secret = oauth2_client_secret
      auth.scope         = SCOPE
      auth.access_token  = current_access_token
      auth.refresh_token = current_refresh_token
    end

    def set_api_client_info(api_client)
      # api_client.authorization = :oauth_2
      set_auth_info(api_client.authorization)
      api_client.auto_refresh_token = true
    end

    def create_api_client
      Google::APIClient.new.tap(&method(:set_api_client_info))
    end

    def http
      return @http if @http
      endpoint = URI.parse(ENDPOINT)
      # Have to do all this garbage because Net::HTTP has a hard time
      # knowing what https is without hand holding.
      @http = Net::HTTP.new(endpoint.host, endpoint.port).tap do |http|
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
    end

    def process_authorization_code(code)
      puts "QUERYING GOOGLE" # TODO remove or replace with rails logger
      response = http.post(ENDPOINT_PATH, authentication_params(code), header)

      case response
      when Net::HTTPSuccess then
        data = JSON.parse response.body
        google_error(data) if data['error']

        self.current_access_token  = data['access_token']
        if data['refresh_token'].nil?
          logger.warn "No refresh token given in response"
        else
          self.current_refresh_token = data['refresh_token']
        end
        self.current_expiration_date = data['expires_in'].seconds.from_now

        save!
      else
        raise Error, "HTTP request to #{ENDPOINT} failed: #{response}"
      end
    end

    def update_from(refresh_result)
      if refresh_result['access_token'] && refresh_result['expires_in']
        self.current_access_token = refresh_result['access_token']
        self.current_expiration_date = Time.now + refresh_result['expires_in']
        save
      else
        false
      end
    end

    def authentication_url(user = nil)
      AUTHENTICATION + '?' + URI.encode_www_form(user_prompt_params(user))
    end

    def authenticated?
      # TODO since valid_token doesn't work, we don't want to actually check 
      #      like this
      # begin
      #   !valid_token.nil?
      # rescue Error => e
      #   @why_not = e
      # end
      return false if oauth2_client_secret.nil?

      !current_access_token.nil? || !current_refresh_token.nil?
    end

    def temporarily_authenticated?
      !current_access_token.nil? && current_refresh_token.nil?
    end

    def has_token?
      !current_access_token.nil?
    end

    def has_client_and_secret?
      !oauth2_client_id.nil? && !oauth2_client_secret.nil?
    end

    def valid_token
      raise "TODO this doesn't work; don't use it right now :("

      unless has_client_and_secret?
        raise Error, "Must have client and secret before authenticating"
      end
      return current_access_token if expires_in > 0

      # TODO this doesn't quite seem to work (gets 400 bad request)
      response = http.post(ENDPOINT_PATH, refresh_params, header)
      case response
      when Net::HTTPSuccess then
        data = JSON.parse response.body
        google_error(data) if data['error']

        self.current_access_token = data['access_token']
        self.current_expiration_date = data['expires_in']

        save!
      else
        raise Error, "HTTP request to #{ENDPOINT + ENDPOINT_PATH} failed: #{response.inspect}"
      end
    end

    def expires_in
      return nil if current_expiration_date.nil?
      (current_expiration_date - Time.now.to_i)
    end

    private

    def google_error(data)
      raise "GOOGLE ERROR: #{data['error']}: #{data['error_description']}"
    end

    def authentication_params(code)
      require_client_id_and_secret
      {
        code:          code,
        client_id:     oauth2_client_id,
        client_secret: oauth2_client_secret,
        redirect_uri:  admin_oauth2_callback_url,
        grant_type:    'authorization_code',
      }
        .to_param
    end

    def user_prompt_params(user = nil)
      require_client_id_and_secret
      {
        response_type: 'code',
        client_id:     oauth2_client_id,
        redirect_uri:  admin_oauth2_callback_url,
        scope:         SCOPE,
        state:         self.class.scramble_state_token!,
        access_type:   'offline',
        login_hint:    user.try(:email),
        approval_prompt: 'force'
      }
    end

    def refresh_params
      require_client_id_and_secret
      {
        client_secret: oauth2_client_secret,
        grant_type:   'refresh_token',
        refresh_token: current_refresh_token,
        client_id:     oauth2_client_id
      }
        .to_param
    end

    def require_client_id_and_secret
      unless has_client_and_secret?
        raise Error, "Must specify client id and secret"
      end
    end

    def header
      {
        'content-type' => 'application/x-www-form-urlencoded',
      }
    end
  end
end
