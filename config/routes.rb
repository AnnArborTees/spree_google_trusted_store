Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :spree_trusted_store_settings
  end
end
