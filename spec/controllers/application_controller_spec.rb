require 'rails_helper'

describe ApplicationController do
  describe "authorization exception handler" do
    controller do
      def index
        raise Pundit::NotAuthorizedError
      end
    end

    before { get :index }

    it "sets a flash" do
      expect(flash[:danger]).to_not be_nil
    end

    it "stores the current location in the session" do
      expect(session[:return_to]).to eq request.original_url
    end

    it "redirects to the signin page" do
      expect(response).to redirect_to signin_path
    end
  end

  describe "#not_authorized_message" do
    describe "when a translation corresponding to the associated policy and query method" do
      let(:scope) { 'p' }
      subject { response.body }

      context "is available" do
        controller(EmailConfirmationsController) do
          def edit
            render text: not_authorized_message
          end
        end

        let(:policy_name) { request.params[:controller].sub(/s\z/, '') }
        let(:query)       { request.params[:action] + '?' }

        before { get :edit, id: 'foo' }

        it "returns a translated message" do
          expect(subject).to eq t("#{policy_name}.#{query}", scope: scope)
        end
      end

      context "is not available" do
        controller(UsersController) do
          def new
            render text: not_authorized_message
          end
        end

        before { get :new }

        it "returns the default message" do
          expect(subject).to eq t('default', scope: scope)
        end
      end
    end
  end

  describe "#set_last_seen_at" do
    controller do
      def index
        render nothing: true # do nothing other than invoke filters
      end
    end

    let(:user) { FactoryGirl.create(:user) }

    subject { get(:index, {}, last_seen_at: last_seen_at) } # the last parameter is a session hash

    before { sign_in_as(user, no_capybara: true) }

    shared_examples "shared" do
      it "stores the current time in it" do
        expect { subject }.to change {
          session[:last_seen_at]
        }.to(ActiveSupport::TimeWithZone)
      end

      it "updates the current user's last_seen_at attribute" do
        expect { subject }.to change{
          user.reload.last_seen_at
        }.from(nil).to(ActiveSupport::TimeWithZone)
      end
    end

    context "when the last_seen_at session key is not set" do
      let(:last_seen_at) { nil }

      include_examples "shared"
    end

    context "when the last_seen_at session key was last updated 3 or more minutes ago" do
      let(:last_seen_at) { 3.minutes.ago }

      include_examples "shared"
    end

    context "when the last_seen_at session key was last updated less than 3 minutes ago" do
      let(:last_seen_at) { 2.minutes.ago }

      it "does not change it" do
        subject
        expect(session[:last_seen_at]).to eq(last_seen_at)        
      end

      it "does not change the current user's last_seen_at attribute" do
        expect { subject }.to_not change{ user.reload.last_seen_at }
      end
    end
  end

  describe "#set_locale" do
    controller do
      def index
        render nothing: true # do nothing other than invoke filters
      end
    end

    subject(:current_locale) { I18n.locale }

    before { I18n.locale = I18n.default_locale }

    context "when a locale param is passed in the url" do
      let(:locale_param) { :ru }
      before { get :index, locale: locale_param }

      it "sets the locale based on it" do
        expect(subject).to eq locale_param
      end
    end

    context "when a locale param is not passed in the url" do
      context "when the user is signed in" do
        let(:user) { FactoryGirl.create(:user, locale: :ru) }
        before do
          sign_in_as(user, no_capybara: true)
          get :index
        end

        it "sets the locale based on the user's preferences" do
          expect(subject).to eq user.locale
        end
      end

      context "when the user is not signed in" do
        shared_examples "shared" do
          it "sets the default locale" do
            expect(subject).to eq I18n.default_locale
          end

          it "saves the default locale in the cookie" do
            expect(response.cookies['locale']).to eq I18n.default_locale.to_s
          end
        end

        context "and a locale cookie is set" do
          before do
            request.cookies['locale'] = cookie_locale
            get :index
          end

          context "to a known locale" do
            let(:cookie_locale) { 'ru' }
            
            it "sets the locale as specified in the cookie" do
              expect(subject.to_s).to eq cookie_locale
            end
          end

          context "to an unknown locale" do
            let(:cookie_locale) { 'es' }

            include_examples "shared"
          end
        end

        context "and a locale cookie is not set" do
          before { get :index }

          include_examples "shared"
        end
      end
    end
  end
end