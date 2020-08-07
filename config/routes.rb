Rails.application.routes.draw do
  get "/healthcheck", to: "monitoring#healthcheck"
  root "home#show"
end
