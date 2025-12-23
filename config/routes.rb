Rails.application.routes.draw do
  default_url_options(host: Decor::Routes.host, protocol: Decor::Routes.protocol)

  root "home#index"

  resources :computers, only: :index
  resources :components, only: :index
  resources :owners, only: %i[index show new create edit update] do
    resources :computers, controller: "owners/computers"
    resources :components, controller: "owners/components"
  end

  resource :session, only: %i[new create destroy]
  resources :password_resets, only: %i[new create edit update], param: :token

  namespace :admin do
    resources :owners, only: %i[index new create edit update destroy] do
      member do
        post :send_password_reset
      end
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
  mount LetterOpenerWeb::Engine, at: "/letters" if Rails.env.development?
end
