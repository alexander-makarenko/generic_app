Rails.application.routes.draw do

  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
  
  get '/', to: redirect("/#{I18n.default_locale}"), as: 'root'
  get ':locale' => 'static_pages#home', locale: /en|ru/, as: 'localized_root'

  # get '*path', to: redirect("/#{I18n.default_locale}/%{path}")

  scope '(:locale)', locale: /en|ru/ do
    resources :users, only: [:update]

    scope controller: :users do
      get  'signup'             => :new
      post 'signup'             => :create
      get  'users/:id/settings' => :edit, as: 'settings'
      post 'users/validate'     => :validate, as: 'users_validation'
    end

    scope controller: :sessions do
      get    'signin'  => :new
      post   'signin'  => :create
      delete 'signout' => :destroy
    end
  
    scope path: 'user' do      
      scope controller: :account_activations do
        get  'activate'                      => :new,    as: 'new_account_activation'
        post 'activate'                      => :create, as: 'account_activations'
        get  'activate/:hashed_email/:token' => :edit,   as: 'edit_account_activation'
      end

      scope controller: :password_resets do
        get   'recover'                      => :new,    as: 'new_password_reset'
        post  'recover'                      => :create, as: 'password_resets'
        get   'recover/:hashed_email/:token' => :edit,   as: 'edit_password'
        patch 'recover'                      => :update
      end

      scope controller: :password_changes do
        get  'change-password' => :new,    as: 'new_password_change'
        post 'change-password' => :create, as: 'password_changes'
      end
    end
  end
end