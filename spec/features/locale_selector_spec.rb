require 'rails_helper'

feature "Locale selector" do  
  given(:user) { FactoryGirl.create(:user) }
  given(:locale_switcher) { '#locale-selector' }
  given(:settings_link) { t 'v.layouts._header.nav_links.settings' }

  shared_examples "a locale selector" do
    given(:english) { t 'v.shared._locale_selector.en' }
    given(:russian) { t 'v.shared._locale_selector.ru' }

    subject { page.find(locale_switcher) }

    def locale_cookie
      get_me_the_cookie('locale')[:value]
    end

    it "lists the available locales" do
      [english, russian].each do |locale_name|
        expect(subject).to have_content(locale_name).or have_button(locale_name)
      end
    end

    it "has a button for all locales except the current one" do
      expect(subject).to_not  have_button english
      expect(subject).to      have_button russian
    end

    context "when a button is clicked" do
      it "switches the current locale" do
        expect { subject.click_button russian }.to change {
          I18n.locale
        }.from(:en).to(:ru)
      end

      it "sets the locale cookie" do
        expect { subject.click_button russian }.to change {
          locale_cookie
        }.from('en').to('ru')
      end

      it "leaves the user on the same page" do
        expect { subject.click_button russian }.to_not change { current_path }
      end
    end
  end

  context "when the user is not signed in" do
    background { visit signin_path }

    it "is shown in the layout" do
      expect(page).to have_selector locale_switcher
    end

    it_behaves_like "a locale selector"
  end
  
  context "when the user is signed in" do
    background do
      visit signin_path
      sign_in_as user
      page.find('#accountDropdown').click
      click_link settings_link
    end

    it "is not shown in the layout" do
      visit root_path
      expect(page).to_not have_selector locale_switcher
    end

    it "is shown on the users's profile page" do
      within('.main') { expect(page).to have_selector locale_switcher }
    end

    it_behaves_like "a locale selector"
  end
end