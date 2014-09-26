PostitTemplate::Application.routes.draw do
  root to: 'posts#index'

  resources :posts, except: [:destroy] do
  	resources :comments, only: [:create]
  	collection do
  		get "search"
  	end
  end
  
  resources :users, only: [:new, :create] do
  	collection do
  		get "search"
    end

    member do
      get "posts"
  	end

  end

  resources :categories, except: [:destroy]

end
