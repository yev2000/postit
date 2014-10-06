PostitTemplate::Application.routes.draw do
  root to: 'posts#index'

  get '/register', to: 'users#new'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  get '/logout', to: 'sessions#destroy'

  resources :posts, except: [:destroy] do
  	resources :comments, only: [:create] do
      member do
        post "vote"
      end
    end

  	collection do
  		get "search"
  	end

    member do
      post "vote"
    end
  end
  
  resources :users, only: [:show, :edit, :create, :update] do
  	collection do
  		get "search"
      get "admin_edit"
    end

    member do
      get "posts"
  	end

  end

  resources :categories, except: [:destroy]

end
