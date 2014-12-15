module Spree
  class GoogleErrorMailer < BaseMailer
    class << self
      attr_accessor :last_error_message
    end

    def helper_error(e)
      recipient, sender, subject = basic_info('Google Merchant error')
      @error = e
      mail(to: recipient, from: sender, subject: subject)
    end

    def upload_task_error(variant_errors)
      recipient, sender, subject = basic_info('Google upload task error')
      @variant_errors = variant_errors
      mail(to: recipient, from: sender, subject: subject)
    end

    private

    def basic_info(error_name)
      [
        'devteam@annarbortees.com',
        'error_brigade@annarbortees.com',
        "#{error_name} #{Time.now.strftime('%c')}"
      ]
    end
  end
end
