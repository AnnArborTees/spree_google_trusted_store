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
    
    # admin_oauth2_callback_url
    get '/oauth2/callback', to: 'google_shopping_settings#oauth2', as: :oauth2_callback
  end
  get '/google_trusted_store/feed/shipment', to: 'google_feed#shipment', as: :google_trusted_store_shipment_feed
  get '/google_trusted_store/feed/cancellation', to: 'google_feed#cancellation', as: :google_trusted_store_cancellation_feed

  get '/products/:id/:variant_id', to: 'products#show', as: :product_variant
end
