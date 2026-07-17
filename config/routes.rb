Rails.application.routes.draw do
  # Devise routes using your custom controllers
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }

  # Custom Devise Path Aliases
  devise_scope :user do
    # Sign Up
    get "/signup", to: "users/registrations#new", as: :signup
    post "/signup", to: "users/registrations#create"

    # Sign In / Log In (This fixes your login_path issue!)
    get "/login", to: "users/sessions#new", as: :login
    post "/login", to: "users/sessions#create"

    # Sign Out / Log Out (This gives you logout_path!)
    delete "/logout", to: "users/sessions#destroy", as: :logout

    root to: "users/sessions#new"
  end

  # Shop Keeper Namespace
  namespace :shop_keeper do
    get "dashboard", to: "dashboard#index"
    get "accounting", to: "accounting#index"

    resources :categories
    resources :reports, only: [ :index ]
    resources :staff
    resources :inventory, only: [ :index ]
    resource :store_switch, only: [ :update ]
    resources :receipts, only: [ :show ]

    resources :products do
      collection do
        get :archived
      end
      member do
        patch :restore
      end
    end

    resources :sales, only: [ :index, :new, :create, :show ] do
      collection do
        get :success
        get :history
      end
    end
  end

  # Admin Namespace
  namespace :admin do
    resources :users
    resources :products do
      resources :stock_movements, only: [ :index ]
    end
    resources :inventory_adjustments, only: [ :new, :create ]
  end

  # Base Demo / Root
  get "access_denied", to: "access_denied#index"


  # Health Check
  get "up" => "rails/health#show", as: :rails_health_check
end
