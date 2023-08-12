Rails.application.routes.draw do
  use_doorkeeper
  devise_for :accounts

  resources :accounts, only: [:update, :destroy] do
    get :current, on: :collection
  end
end
