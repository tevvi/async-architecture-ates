require 'karafka/web'

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  mount Karafka::Web::App, at: '/karafka'

  get 'auth/:provider/callback', to: 'sessions#create'

  get '/dashboard', to: 'tasks#index'
  post 'tasks/create', to: 'tasks#create'
  put 'tasks/:public_id/complete', to: 'tasks#complete'
  put 'tasks/reassign', to: 'tasks#reassign'
end
