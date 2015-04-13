require 'rails_helper'

describe "Routing" do
  locales = [ nil, '/en', '/ru' ]
  locales.each do |locale|
    describe "in AccountActivations controller" do
      specify do
        expect(get "#{locale}/user/activate/hashed_email/token").to route_to(
          'account_activations#edit', { hashed_email: 'hashed_email',
            token: 'token' }.merge(locale_param(locale)))
      end
      
      specify do
        expect(get "#{locale}/user/activate").to route_to(
          'account_activations#new', locale_param(locale))
      end
      
      specify do
        expect(post "#{locale}/user/activate").to route_to(
          'account_activations#create', locale_param(locale))
      end
    end

    describe "in PasswordChanges controller" do
      specify do
        expect(get "#{locale}/user/change-password").to route_to(
          'password_changes#new', locale_param(locale))
      end

      specify do
        expect(post "#{locale}/user/change-password").to route_to(
          'password_changes#create', locale_param(locale))
      end
    end

    describe "in PasswordResets controller" do
      specify do
        expect(get "#{locale}/user/recover").to route_to(
          'password_resets#new', locale_param(locale))
      end

      specify do
        expect(post "#{locale}/user/recover").to route_to(
          'password_resets#create', locale_param(locale))
      end

      specify do
        expect(get "#{locale}/user/recover/hashed_email/token").to route_to(
          'password_resets#edit', { hashed_email: 'hashed_email',
            token: 'token' }.merge(locale_param(locale)))
      end

      specify do
        expect(patch "#{locale}/user/recover").to route_to(
          'password_resets#update', locale_param(locale))
      end
    end
  
    describe "in Sessions controller" do
      specify do
        expect(get "#{locale}/signin").to route_to(
          'sessions#new', locale_param(locale))
      end

      specify do
        expect(post "#{locale}/signin").to route_to(
          'sessions#create', locale_param(locale))
      end

      specify do
        expect(delete "#{locale}/signout").to route_to(
          'sessions#destroy', locale_param(locale))
      end
    end

    describe "in StaticPages controller" do
      specify do
        expect(get "#{locale}/").to route_to(
          'static_pages#home', locale_param(locale))
      end
    end

    describe "in Users controller" do
      specify { expect(get "#{locale}/users").to_not be_routable }
      specify { expect(get "#{locale}/users/42/edit").to_not be_routable }
      specify { expect(get "#{locale}/users/new").to_not be_routable }
      specify { expect(get "#{locale}/users/42").to_not be_routable }
      specify { expect(delete "#{locale}/users/42").to_not be_routable }
      
      specify do
        expect(post "#{locale}/signup").to route_to(
          'users#create', locale_param(locale))
      end

      specify do
        expect(get "#{locale}/signup").to route_to(
          'users#new', locale_param(locale))
      end

      specify do
        expect(get "#{locale}/users/42/settings").to route_to(
          'users#edit', { id: '42' }.merge(locale_param(locale)))
      end

      specify do
        expect(put "#{locale}/users/42").to route_to(
          'users#update', { id: '42' }.merge(locale_param(locale)))
      end

      specify do
        expect(patch "#{locale}/users/42").to route_to(
          'users#update', { id: '42' }.merge(locale_param(locale)))
      end

      specify do
        expect(post "#{locale}/users/validate").to route_to(
          'users#validate', locale_param(locale))
      end
    end
  end
end