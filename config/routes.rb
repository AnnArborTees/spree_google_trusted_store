Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :google_trusted_store_settings
    resources :google_shopping_settings, only: ['update']
    resources :google_products do
      member do
        post :google_insert, as: :google_insert
      end
    end
    
    get '/google_shopping_settings/edit', to: 'google_shopping_settings#edit'
    
    get '/oauth2/callback', to: 'google_shopping_settings#oauth2'
  end
  get '/google_trusted_store/feed/shipment', to: 'google_feed#shipment', as: :google_trusted_store_shipment_feed
  get '/google_trusted_store/feed/cancelation', to: 'google_feed#cancelation', as: :google_trusted_store_cancelation_feed
end
