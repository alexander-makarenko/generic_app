require 'rails_helper'

describe ApplicationController do
  controller do
    def index
      render nothing: true # do nothing other than invoke filters
    end
  end

  describe "#set_locale" do
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

        it "sets the locale based on the user preferences" do
          expect(subject).to eq user.locale
        end
      end

      context "when the user is not signed in" do
        let(:default_locale) { I18n.default_locale }

        shared_examples "shared" do
          it "sets the default locale" do
            expect(subject).to eq default_locale
          end

          it "saves the default locale in the cookie" do
            expect(response.cookies['locale']).to eq default_locale.to_s
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