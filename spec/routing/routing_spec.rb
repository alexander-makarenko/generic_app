require 'rails_helper'

describe "Routing" do
  locale_prefixes = [ nil, '/en', '/ru' ]

  def locale_prefix_to_param(prefix)
    prefix.nil? ? {} : { locale: prefix.gsub('/', '') }
  end

  shared_context "metadata options" do
    url, method = metadata[:description].dup, metadata[:method]
    let(:url) { url }
    let(:method) { method }

    # modifies example group description for better readability
    metadata[:description] = "#{method.upcase} to #{url}"
  end

  shared_examples is_routable: true do
    include_context "metadata options"
    it "routes to" do |example|
      example.metadata[:description] = "#{example.metadata[:description]} #{target} with #{params}"
      expect(send(method, url)).to route_to(target, params)
    end
  end

  shared_examples is_routable: false do
    include_context "metadata options"
    it "is not routable" do
      expect(send(method, url)).to_not be_routable
    end
  end

  describe "in EmailConfirmations controller" do
    locale_prefixes.each do |prefix|

      describe "#{prefix}/user/confirm/hashed_email/token", method: :get, is_routable: true do
        let(:target) { 'email_confirmations#edit' }
        let(:params) { { hashed_email: 'hashed_email', token: 'token' }.merge locale_prefix_to_param(prefix) }
      end

      describe "#{prefix}/user/confirm", method: :post, is_routable: true do
        let(:target) { 'email_confirmations#create' }
        let(:params) { locale_prefix_to_param(prefix) }
      end
    end
  end

  describe "in EmailChanges controller" do
    locale_prefixes.each do |prefix|

      describe "#{prefix}/user/change-email", method: :get, is_routable: true do
        let(:target) { 'email_changes#new' }
        let(:params) { locale_prefix_to_param(prefix) }
      end

      describe "#{prefix}/user/change-email", method: :post, is_routable: true do
        let(:target) { 'email_changes#create' }
        let(:params) { locale_prefix_to_param(prefix) }
      end

      describe "#{prefix}/user/change-email", method: :delete, is_routable: true do
        let(:target) { 'email_changes#destroy' }
        let(:params) { locale_prefix_to_param(prefix) }
      end
    end
  end

  describe "in PasswordChanges controller" do
    locale_prefixes.each do |prefix|

      describe "#{prefix}/user/change-password", method: :get, is_routable: true do
        let(:target) { 'password_changes#new' }
        let(:params) { locale_prefix_to_param(prefix) }
      end

      describe "#{prefix}/user/change-password", method: :post, is_routable: true do
        let(:target) { 'password_changes#create' }
        let(:params) { locale_prefix_to_param(prefix) }
      end
    end
  end

  describe "in NameChanges controller" do
    locale_prefixes.each do |prefix|

      describe "#{prefix}/user/change-name", method: :get, is_routable: true do
        let(:target) { 'name_changes#new' }
        let(:params) { locale_prefix_to_param(prefix) }
      end

      describe "#{prefix}/user/change-name", method: :post, is_routable: true do
        let(:target) { 'name_changes#create' }
        let(:params) { locale_prefix_to_param(prefix) }
      end
    end
  end

  describe "in PasswordResets controller" do
    locale_prefixes.each do |prefix|

      describe "#{prefix}/user/recover", method: :get, is_routable: true do
        let(:target) { 'password_resets#new' }
        let(:params) { locale_prefix_to_param(prefix) }
      end

      describe "#{prefix}/user/recover", method: :post, is_routable: true do
        let(:target) { 'password_resets#create' }
        let(:params) { locale_prefix_to_param(prefix) }
      end

      describe "#{prefix}/user/recover/hashed_email/token", method: :get, is_routable: true do
        let(:target) { 'password_resets#edit' }
        let(:params) { { hashed_email: 'hashed_email', token: 'token' }.merge locale_prefix_to_param(prefix) }
      end

      describe "#{prefix}/user/recover", method: :patch, is_routable: true do
        let(:target) { 'password_resets#update' }
        let(:params) { locale_prefix_to_param(prefix) }
      end
    end
  end

  describe "in Sessions controller" do
    locale_prefixes.each do |prefix|

      describe "#{prefix}/signin", method: :get, is_routable: true do
        let(:target) { 'sessions#new' }
        let(:params) { locale_prefix_to_param(prefix) }
      end

      describe "#{prefix}/signin", method: :post, is_routable: true do
        let(:target) { 'sessions#create' }
        let(:params) { locale_prefix_to_param(prefix) }
      end

      describe "#{prefix}/signout", method: :delete, is_routable: true do
        let(:target) { 'sessions#destroy' }
        let(:params) { locale_prefix_to_param(prefix) }
      end
    end
  end

  describe "in StaticPages controller" do
    locale_prefixes.drop(1).each do |prefix|

      describe "#{prefix}/", method: :get, is_routable: true do
        let(:target) { 'static_pages#home' }
        let(:params) { locale_prefix_to_param(prefix) }
      end
    end
  end

  describe "in Users controller" do
    locale_prefixes.each do |prefix|

      describe "#{prefix}/users", method: :get, is_routable: true do # resourceful index
        let(:target) { 'users#index' }
        let(:params) { locale_prefix_to_param(prefix) }
      end         
      
      describe "#{prefix}/users/42", method: :get, is_routable: true do # resourceful show
        let(:target) { 'users#show' }
        let(:params) { { id: '42' }.merge locale_prefix_to_param(prefix) }
      end
      
      # describe "#{prefix}/users/42/edit", method: :get, is_routable: false do; end # resourceful edit
      # describe "#{prefix}/users/42", method: :put, is_routable: false do; end      # resourceful update
      # describe "#{prefix}/users/42", method: :patch, is_routable: false do; end    # resourceful update
      # describe "#{prefix}/users/42", method: :delete, is_routable: false do; end   # resourceful destroy

      describe "#{prefix}/signup", method: :get, is_routable: true do
        let(:target) { 'users#new' }
        let(:params) { locale_prefix_to_param(prefix) }
      end

      describe "#{prefix}/signup", method: :post, is_routable: true do
        let(:target) { 'users#create' }
        let(:params) { locale_prefix_to_param(prefix) }
      end

      describe "#{prefix}/account", method: :get, is_routable: true do
        let(:target) { 'users#show' }
        let(:params) { locale_prefix_to_param(prefix) }
      end

      describe "#{prefix}/users/validate", method: :post, is_routable: true do
        let(:target) { 'users#validate' }
        let(:params) { locale_prefix_to_param(prefix) }
      end
    end
  end

  describe "in Locale controller" do
    locale_prefixes.each do |prefix|

      describe "#{prefix}/set-locale", method: :post, is_routable: true do
        let(:target) { 'locale_changes#create' }
        let(:params) { locale_prefix_to_param(prefix) }
      end
    end
  end

  describe "in Avatars controller" do
    locale_prefixes.each do |prefix|

      describe "#{prefix}/user/avatar", method: :get, is_routable: true do
        let(:target) { 'avatars#new' }
        let(:params) { locale_prefix_to_param(prefix) }
      end

      describe "#{prefix}/user/avatar", method: :post, is_routable: true do
        let(:target) { 'avatars#create' }
        let(:params) { locale_prefix_to_param(prefix) }
      end

      describe "#{prefix}/user/avatar", method: :delete, is_routable: true do
        let(:target) { 'avatars#destroy' }
        let(:params) { locale_prefix_to_param(prefix) }
      end
    end
  end
end