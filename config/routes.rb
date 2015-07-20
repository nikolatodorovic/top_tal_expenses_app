Rails.application.routes.draw do
  root 'home#index'

  namespace :api, defaults: {format: :json} do
    resources :users, except: [:new, :edit]
    resources :expenses, except: [:new, :edit] do
      collection do 
        get :weekly
      end
    end
  end

  post '/auth/register', to: 'auth#register', defaults: {format: :json}
  post '/auth/authenticate', to: 'auth#authenticate', defaults: {format: :json}
  get '/auth/token_status', to: 'auth#token_status', defaults: {format: :json}

end
