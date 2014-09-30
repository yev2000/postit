PostitTemplate::Application.routes.draw do
  root to: 'posts#index'

  get '/register', to: 'users#new'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  get '/logout', to: 'sessions#destroy'

  resources :posts, except: [:destroy] do
  	resources :comments, only: [:create]
  	collection do
  		get "search"
  	end
  end
  
  resources :users, only: [:new, :edit, :create, :update] do
  	collection do
  		get "search"
    end

    member do
      get "posts"
  	end

  end

  resources :categories, except: [:destroy]

end
