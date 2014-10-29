module Spree
  class GoogleTrustedStoreSetting < ActiveRecord::Base
    validates :account_id, length: { is: 6 }

    before_validation on: :create do
      self.account_id = '000000'
      self.default_locale = 'en_US'
    end

    def self.instance
      first or create
    end

    def self.create
      all.exists? ? first : super
    end
  end

  class GoogleTrustedStoreSettings
    def self.respond_to?(*args)
      super or GoogleTrustedStoreSetting.instance.respond_to?(*args)
    end

    def self.method_missing(name, *args, &block)
      GoogleTrustedStoreSetting.instance.send(name, *args, &block)
    end
  end
end