Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  get "/health", to: "health#index"

  namespace :api do
    namespace :v1 do
      post "auth/login",
        to: "auth#login"

      get "protected",
        to: "protected#show"

      post "organizations/:organization_id/select",
        to: "organizations#select", as: :select_organization

      get "organizations/:id",
        to: "organizations#show"

      resources :clients,
        only: [:index, :create, :show, :update, :destroy]

      resources :projects,
        only: [:index, :create, :show, :update, :destroy]

    end
  end

end
