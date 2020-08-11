Rails.application.routes.draw do
  devise_for :users
  get "/healthcheck", to: "monitoring#healthcheck"
  root "home#show"
end
