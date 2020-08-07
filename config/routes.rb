Rails.application.routes.draw do
  get "/healthcheck", to: "monitoring#healthcheck"
  get "/", to: "home#show"
end
