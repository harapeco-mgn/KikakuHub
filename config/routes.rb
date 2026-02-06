Rails.application.routes.draw do
  root "home#index"
  devise_for :users, controllers: { registrations: "users/registrations" }

  resource :mypage, only: %i[show]

  scope :profile, as: :profile, module: :profiles do
  resources :availability_slots, path: "availability", only: %i[index destroy] do
    collection do
      patch :bulk_update
      post  :bulk_create
      patch :overwrite_copy_category
      delete :destroy_all
    end
  end
end

  resources :themes, only: %i[index show new create destroy] do
  scope module: :themes do
    resource  :vote,           only: %i[create destroy]
    resources :theme_comments, only: %i[create destroy]
    resource :rsvp,            only: [ :update ]
  end
end
  get "guidance", to: "static_pages#guidance"

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
