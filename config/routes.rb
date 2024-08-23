Rails.application.routes.draw do
  resources :tasks
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.

  # Defines the root path route ("/")
  root "static_pages#top"
  get "explanation", to: "static_pages#explanation"
  get "privacy_policy", to: "static_pages#privacy"
  get "terms_of_service", to: "static_pages#condition"

  get 'user_top', to: 'homes#top'

  resources :users, only: %i[new create]
  get 'login', to: 'user_sessions#new'
  post 'login', to: 'user_sessions#create'
  delete 'logout', to: 'user_sessions#destroy'
  resource :profile, only: %i[edit update show]
  resources :recipes, only: %i[index new create edit show update destroy] do
    collection do
      get :create_index
    end
  end
  namespace :openai do
    get 'ask_question', to: 'change#ask_question'
    post 'generate_recipe', to: 'change#generate_recipe'
    get 'show_recipe', to: 'change#show_recipe'
  end

end
