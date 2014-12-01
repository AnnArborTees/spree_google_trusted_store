module Spree
  class GoogleErrorMailer < BaseMailer
    def helper_error(e)
      recipient = 'devteam@annarbortees.com'
      sender    = 'error_brigade@annarbortees.com'
      subject = %(
        Google Merchant error #{Time.now.strftime('%c')}
      )

      @error = e

      mail(to: recipient, from: sender, subject: subject)
    end
  end
end
