Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :spree_google_trusted_store_settings
  end
end
