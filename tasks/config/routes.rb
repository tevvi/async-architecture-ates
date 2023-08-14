require 'karafka/web'

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  mount Karafka::Web::App, at: '/karafka'

  get 'auth/:provider/callback', to: 'sessions#create'
  get '/login', to: 'sessions#new'
end
