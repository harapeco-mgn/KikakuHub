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

  resources :themes, only: %i[index show new create edit update destroy] do
    collection do
      get :archived
    end
    member do
      patch :transition
      patch :hide
      patch :unhide
    end
    scope module: :themes do
      resource  :vote,           only: %i[create destroy]
      resources :theme_comments, only: %i[create destroy] do
        member do
          patch :hide
          patch :unhide
        end
        scope module: :theme_comments do
          resources :reports, only: %i[create]
        end
      end
      resource :rsvp,            only: [ :update ]
      resources :reports, only: %i[create]
    end
  end

  resources :notifications, only: [ :index ] do
    member { patch :read }
    collection { patch :read_all }
  end

  namespace :admin do
    resource :dashboard, only: %i[show]
    resources :reports, only: %i[index] do
      member do
        patch :review
        patch :dismiss
      end
    end
    resources :users, only: %i[index show] do
      member { patch :update_role }
    end
    resources :themes, only: %i[index show]
  end

  get "guidance", to: "static_pages#guidance"

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
