Rails.application.routes.draw do
  get 'session/new'
  root 'static_pages#home'
  get '/help', to: 'static_pages#help'
  get '/about', to: 'static_pages#about'
  get '/contact', to: 'static_pages#contact'
  get '/signup', to: 'users#new'
  get '/login', to: 'session#new'
  post '/login', to: 'session#create'
  delete '/logout', to: 'session#destroy'
  # arranges the /users/1/following and /users/1/followers routesm the member method arranges the routes to respond to URLs containing the user id
  resources :users do
    member do
      get :following, :followers
    end
  end
  # This will define only the edit action, that will allow us to do a get
  resources :account_activations, only: [:edit]
  resources :password_resets, only: %i[new create edit update]
  resources :microposts, only: %i[create destroy]
  resources :relationships, only: %i[create destroy]
  get '/microposts', to: 'static_pages#home'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
end
