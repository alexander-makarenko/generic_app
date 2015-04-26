require 'rails_helper'

describe "Routing" do
  locales = [ nil, '/en', '/ru' ]

  locale_params = locales.map do |locale|
    locale.nil? ? {} : { locale: locale.gsub('/', '') }
  end
  
  describe "in AccountActivations controller routes" do
    locales.each_with_index do |locale, i|
      describe "GET to" do
        url = "#{locale}/user/activate/hashed_email/token"
        params = { hashed_email: 'hashed_email', token: 'token' }.merge locale_params[i]
        target = 'account_activations#edit'
        
        it "#{url} to #{target} | params = #{params}" do
          expect(get url).to route_to(target, params)
        end
      end

      describe "GET to" do
        url = "#{locale}/user/activate"
        params = locale_params[i]
        target = 'account_activations#new'

        it "#{url} to #{target} | params = #{params}" do
          expect(get url).to route_to(target, params)
        end
      end      

      describe "POST to" do
        url = "#{locale}/user/activate"
        params = locale_params[i]
        target = 'account_activations#create'

        it "#{url} to #{target} | params = #{params}" do
          expect(post url).to route_to(target, params)
        end
      end
    end
  end

  describe "in PasswordChanges controller routes" do
    locales.each_with_index do |locale, i|

      describe "GET to" do
        url = "#{locale}/user/change-password"
        params = locale_params[i]
        target = 'password_changes#new'

        it "#{url} to #{target} | params = #{params}" do
          expect(get url).to route_to(target, params)
        end
      end

      describe "POST to" do
        url = "#{locale}/user/change-password"
        params = locale_params[i]
        target = 'password_changes#create'

        it "#{url} to #{target} | params = #{params}" do
          expect(post url).to route_to(target, params)
        end
      end
    end
  end

  describe "in PasswordResets controller routes" do
    locales.each_with_index do |locale, i|

      describe "GET to" do
        url = "#{locale}/user/recover"
        target = 'password_resets#new'
        params = locale_params[i]

        it "#{url} to #{target} | params = #{params}" do
          expect(get url).to route_to(target, params)
        end
      end

      describe "POST to" do
        url = "#{locale}/user/recover"
        params = locale_params[i]
        target = 'password_resets#create'

        it "#{url} to #{target} | params = #{params}" do
          expect(post url).to route_to(target, params)
        end
      end

      describe "GET to" do
        url = "#{locale}/user/recover/hashed_email/token"
        params = { hashed_email: 'hashed_email', token: 'token' }.merge locale_params[i]
        target = 'password_resets#edit'

        it "#{url} to #{target} | params = #{params}" do
          expect(get url).to route_to(target, params)
        end
      end

      describe "PATCH to" do
        url = "#{locale}/user/recover"
        params = locale_params[i]
        target = 'password_resets#update'

        it "#{url} to #{target} | params = #{params}" do
          expect(patch url).to route_to(target, params)
        end
      end
    end
  end

  describe "in Sessions controller routes" do
    locales.each_with_index do |locale, i|

      describe "GET to" do
        url = "#{locale}/signin"
        params = locale_params[i]
        target = 'sessions#new'

        it "#{url} to #{target} | params = #{params}" do
          expect(get url).to route_to(target, params)
        end
      end

      describe "POST to" do
        url = "#{locale}/signin"
        params = locale_params[i]
        target = 'sessions#create'

        it "#{url} to #{target} | params = #{params}" do
          expect(post url).to route_to(target, params)
        end
      end

      describe "DELETE to" do
        url = "#{locale}/signout"
        params = locale_params[i]
        target = 'sessions#destroy'

        it "#{url} to #{target} | params = #{params}" do
          expect(delete url).to route_to(target, params)
        end
      end
    end
  end

  describe "in StaticPages controller routes" do
    locales[1..-1].each_with_index do |locale, i|

      describe "GET to" do
        url = "#{locale}/"
        params = locale_params[i + 1]
        target = 'static_pages#home'

        it "#{url} to #{target} | params = #{params}" do
          expect(get url).to route_to(target, params)
        end
      end
    end    
  end

  describe "in Users controller" do
    locales.each_with_index do |locale, i|

      describe "GET to" do
        url = "#{locale}/users"
        
        it "#{url} is not routable" do
          expect(get url).to_not be_routable
        end
      end

      describe "GET to" do
        url = "#{locale}/users/42/edit"
        
        it "#{url} is not routable" do
          expect(get url).to_not be_routable
        end
      end

      describe " to" do
        url = "#{locale}/users/new"
        
        it "#{url} is not routable" do
          expect(get url).to_not be_routable
        end
      end

      describe "GET to" do
        url = "#{locale}/users/42"
        
        it "#{url} is not routable" do
          expect(get url).to_not be_routable
        end
      end      

      describe "DELETE to" do
        url = "#{locale}/users/42"
        
        it "#{url} is not routable" do
          expect(delete url).to_not be_routable
        end
      end

      describe "POST to" do
        url = "#{locale}/signup"
        params = locale_params[i]
        target = 'users#create'

        it "#{url} to #{target} | params = #{params}" do
          expect(post url).to route_to(target, params)
        end
      end

      describe "GET to" do
        url = "#{locale}/signup"
        params = locale_params[i]
        target = 'users#new'

        it "#{url} to #{target} | params = #{params}" do
          expect(get url).to route_to(target, params)
        end
      end

      describe "GET to" do
        url = "#{locale}/users/42/settings"
        params = { id: '42' }.merge locale_params[i]
        target = 'users#edit'

        it "#{url} to #{target} | params = #{params}" do
          expect(get url).to route_to(target, params)
        end
      end      

      describe "PUT to" do
        url = "#{locale}/users/42"
        params = { id: '42' }.merge locale_params[i]
        target = 'users#update'

        it "#{url} to #{target} | params = #{params}" do
          expect(put url).to route_to(target, params)
        end
      end

      describe "PATCH to" do
        url = "#{locale}/users/42"
        params = { id: '42' }.merge locale_params[i]
        target = 'users#update'

        it "#{url} to #{target} | params = #{params}" do
          expect(patch url).to route_to(target, params)
        end
      end

      describe "POST to" do
        url = "#{locale}/users/validate"
        params = locale_params[i]
        target = 'users#validate'

        it "#{url} to #{target} | params = #{params}" do
          expect(post url).to route_to(target, params)
        end
      end
    end
  end  
end