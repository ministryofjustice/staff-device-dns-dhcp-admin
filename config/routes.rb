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
    resources :exclusions, only: [:new, :create]
    resource :options, only: [:new, :create, :edit, :update, :destroy]
    resource :reservations, only: [:new, :create]
    delete "/reservations", controller: :reservations, action: :destroy_all
    post "/leases", controller: :leases, action: :export

    resources :leases, only: [:index, :destroy]

    resources :extensions, only: [:new, :create], controller: :subnet_extensions
    put "/extensions/update", controller: :subnet_extensions, action: :update, as: :update_extensions
  end

  resources :leases, only: [:destroy]

  resources :reservations, only: [:show, :edit, :update, :destroy] do
    resource :reservation_options, only: [:new, :create], path: "/options"
  end
  resources :exclusions, only: [:show, :destroy]

  resources :reservation_options, only: [:edit, :update, :destroy]

  resources :global_options, only: [:index, :new, :create, :edit, :update, :destroy], path: "/global-options"

  resources :client_classes, path: "/client-classes"

  resources :audits, only: [:index, :show]

  get "/healthcheck", to: "monitoring#healthcheck"

  get "/import", to: "import#index"
  post "/import", to: "import#create"

  root "home#index"
end
