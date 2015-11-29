Rails.application.routes.draw do
  get 'avatars/new'

  get 'avatars/create'

  get 'avatars/destroy'

  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
  
  root 'static_pages#home'
  get ':locale' => 'static_pages#home', locale: /en|ru/
  # get ':locale/*path', locale: /en|ru/, to: redirect('%{path}')

  scope '(:locale)', locale: /en|ru/ do
    resources :users, only: [:show, :index]

    scope controller: :users do
      get  'signup'         => :new
      post 'signup'         => :create
      get  'account'        => :show, as: 'account'
      post 'users/validate' => :validate, as: 'users_validation'
    end

    scope controller: :sessions do
      get    'signin'  => :new
      post   'signin'  => :create
      delete 'signout' => :destroy
    end
  
    scope path: 'user' do
      scope controller: :email_confirmations do
        post 'confirm'                      => :create, as: 'email_confirmations'
        get  'confirm/:hashed_email/:token' => :edit,   as: 'edit_email_confirmation'
      end

      scope controller: :email_changes do
        get    'change-email' => :new,     as: 'new_email_change'
        post   'change-email' => :create,  as: 'email_changes'
        delete 'change-email' => :destroy
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

      scope controller: :name_changes do
        get  'change-name' => :new,    as: 'new_name_change'
        post 'change-name' => :create, as: 'name_changes'
      end

      scope controller: :avatars do
        get    'avatar' => :new,     as: 'new_avatar'
        post   'avatar' => :create,  as: 'avatars'
        delete 'avatar' => :destroy, as: 'avatar'
      end
    end

    scope controller: :locale_changes do
      post 'set-locale' => :create, as: 'locale_changes'
    end
  end
end