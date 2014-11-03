Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :google_trusted_store_settings
  end
  get '/google_trusted_store/feed/shipment', to: 'google_feed#shipment', as: :google_trusted_store_shipment_feed
  get '/google_trusted_store/feed/cancelation', to: 'google_feed#cancelation', as: :google_trusted_store_cancelation_feed
end
