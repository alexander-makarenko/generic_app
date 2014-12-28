require 'rails_helper'

describe "Routing" do
  locales = [ nil, '/en', '/ru' ]
  locales.each do |locale|
    describe "in AccountActivations controller" do    
      specify do
        expect(get "#{locale}/user/activate/abc123").to route_to(
          'account_activations#edit', { token: 'abc123' }.merge(param_from_url(locale)))
      end
      
      specify do
        expect(get "#{locale}/user/activate").to route_to(
          'account_activations#new', param_from_url(locale))
      end
      
      specify do
        expect(post "#{locale}/user/activate").to route_to(
          'account_activations#create', param_from_url(locale))
      end
    end

    describe "in PasswordResets controller" do
      specify do
        expect(get "#{locale}/user/recover").to route_to(
          'password_resets#new', param_from_url(locale))
      end

      specify do
        expect(post "#{locale}/user/recover").to route_to(
          'password_resets#create', param_from_url(locale))
      end

      specify do
        expect(get "#{locale}/user/recover/abc123").to route_to(
          'password_resets#edit', { token: 'abc123' }.merge(param_from_url(locale)))
      end

      specify do
        expect(patch "#{locale}/user/recover").to route_to(
          'password_resets#update', param_from_url(locale))
      end
    end
  
    describe "in Sessions controller" do
      specify do
        expect(get "#{locale}/signin").to route_to(
          'sessions#new', param_from_url(locale))
      end

      specify do
        expect(post "#{locale}/sessions").to route_to(
          'sessions#create', param_from_url(locale))
      end

      specify do
        expect(delete "#{locale}/signout").to route_to(
          'sessions#destroy', param_from_url(locale))
      end
    end

    describe "in StaticPages controller" do
      specify do
        expect(get "#{locale}/").to route_to(
          'static_pages#home', param_from_url(locale))
      end
    end

    describe "in Users controller" do
      specify { expect(get "#{locale}/users").to_not be_routable }
      specify { expect(get "#{locale}/users/42/edit").to_not be_routable }
      specify { expect(get "#{locale}/users/new").to_not be_routable }
      specify { expect(get "#{locale}/users/42").to_not be_routable }
      specify { expect(delete "#{locale}/users/42").to_not be_routable }
      
      specify do
        expect(post "#{locale}/users").to route_to(
          'users#create', param_from_url(locale))
      end

      specify do
        expect(get "#{locale}/signup").to route_to(
          'users#new', param_from_url(locale))
      end

      specify do
        expect(get "#{locale}/users/42/settings").to route_to(
          'users#edit', { id: '42' }.merge(param_from_url(locale)))
      end

      specify do
        expect(put "#{locale}/users/42").to route_to(
          'users#update', { id: '42' }.merge(param_from_url(locale)))
      end

      specify do
        expect(patch "#{locale}/users/42").to route_to(
          'users#update', { id: '42' }.merge(param_from_url(locale)))
      end
    end
  end
end