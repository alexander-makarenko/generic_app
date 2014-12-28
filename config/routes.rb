Rails.application.routes.draw do

  get ':locale' => 'static_pages#home', locale: /en|ru/
  root 'static_pages#home'

  scope '(:locale)', locale: /en|ru/ do
    resources :users, only: [:create, :update]

    scope controller: :users do
      get 'signup'             => :new
      get 'users/:id/settings' => :edit, as: 'settings'
    end

    scope controller: :sessions do
      get    'signin'   => :new
      post   'sessions' => :create
      delete 'signout'  => :destroy
    end
  
    scope path: 'user' do
      scope controller: :account_activations do
        get  'activate'        => :new,    as: 'new_account_activation'
        post 'activate'        => :create, as: 'account_activations'
        get  'activate/:token' => :edit,   as: 'edit_account_activation'
      end

      scope controller: :password_resets do
        get   'recover'        => :new,    as: 'new_password_reset'
        post  'recover'        => :create, as: 'password_resets'
        get   'recover/:token' => :edit,   as: 'edit_password'
        patch 'recover'        => :update
      end
    end
  end
end