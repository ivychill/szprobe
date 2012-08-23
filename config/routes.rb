Szprobe2::Application.routes.draw do
  get 'static_roads/fix'
  
  authenticated :user do
    root :to => 'home#index'
  end
  root :to => "home#index"
  devise_for :users
  resources :users, :only => [:show, :index]
  resources :snaps do
    resources :congested_roads
  end
  resources :static_roads do
    resources :static_pois
  end
end
