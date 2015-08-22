require 'rails_helper'

feature "Locale selector" do  
  given(:locale_switcher) { '#locale-selector' }
  given(:english) { t('v.shared._locale_selector.en') }
  given(:russian) { t('v.shared._locale_selector.ru') }
  given(:links) { { account_settings: t('v.layouts._header.nav_links.settings') } }

  shared_examples "a locale selector" do
    subject { page.find(locale_switcher) }

    def current_locale
      I18n.locale
    end

    it "lists the available locales" do
      [english, russian].each do |locale_name|
        expect(subject).to have_content(locale_name).or have_button(locale_name)
      end
    end

    it "has a button for all locales except the current one" do
      within(locale_switcher) { click_button russian }
      expect(subject).to     have_button english
      expect(subject).to_not have_button russian
    end

    context "when a button is clicked" do
      it "switches the locale" do
        expect(current_locale).to eq :en
        subject.click_button russian
        expect(current_locale).to eq :ru
      end

      it "sets the locale cookie" do
        expect(get_me_the_cookie('locale')[:value]).to eq 'en'
        subject.click_button russian
        expect(get_me_the_cookie('locale')[:value]).to eq 'ru'
      end
    end
  end

  context "when the user is not signed in" do
    background { visit root_path }

    it "is shown in the layout" do
      expect(page).to have_selector(locale_switcher)
    end

    it_behaves_like "a locale selector"
  end
  
  context "when the user is signed in" do
    given(:user) { FactoryGirl.create(:user) }

    background do
      visit signin_path
      sign_in_as user
    end

    it "is not shown in the layout" do
      expect(page).to_not have_selector(locale_switcher)
    end

    it "is shown on the users's profile page" do
      click_link links[:account_settings]
      within('.main') { expect(page).to have_selector(locale_switcher) }
    end

    context "when a button is clicked" do
      it "updates the user's locale preference" do
        click_link links[:account_settings]
        within(locale_switcher) { click_button russian }
        expect(user.reload.locale).to eq :ru
      end
    end

    it_behaves_like "a locale selector" do
      background { click_link links[:account_settings] }
    end
  end
end