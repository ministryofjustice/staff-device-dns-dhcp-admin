Rails.application.routes.draw do
  devise_for :users, controllers: {omniauth_callbacks: "users/omniauth_callbacks"}
  devise_scope :user do
    get "sign_in", to: "devise/sessions#new", as: :new_user_session
    match "sign_out", to: "devise/sessions#destroy", as: :destroy_user_session, via: [:get, :delete]
  end

  get "/dns", to: "zones#index", as: :dns
  resources :zones, except: [:index]

  get "/dhcp", to: "sites#index", as: :dhcp
  resources :sites, except: [:index] do
    resources :subnets, only: [:new, :create]
  end
  resources :subnets, only: [:show, :edit, :update, :destroy] do
    resource :options, only: [:new, :create, :edit, :update, :destroy]
  end
  resources :global_options, only: [:index, :new, :create, :edit, :update, :destroy], path: "/global-options"

  resources :audits, only: [:index, :show]

  get "/healthcheck", to: "monitoring#healthcheck"

  root "home#index"
end
