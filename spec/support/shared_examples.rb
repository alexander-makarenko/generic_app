# add convenience method for I18n.t
def t(string, options={})
  I18n.t(string, options)
end

def switch_locale_to(sym)
  en, ru = t [:en, :ru], scope: 'v.layouts._footer.locale'
  locales = { en: en, ru: ru }
  within('#locale-selector') { click_link locales[sym] }
end

shared_examples "user is not signed in" do |conditions={}|
  it "has signin link", conditions do
    within('header nav') do
      expect(page).to have_link(t('v.layouts._header.nav_links.sign_in'))
    end
  end
  
  it "does not have signout link", conditions do
    within('header nav') do
      expect(page).to_not have_link(t('v.layouts._header.nav_links.sign_out'))
      expect(page).to_not have_link(t('v.layouts._header.nav_links.settings'))
    end
  end
end

shared_examples "user is signed in" do |conditions={}|
  it "has signout link", conditions do
    within('header nav') do
      expect(page).to have_link(t('v.layouts._header.nav_links.sign_out'))
      expect(page).to have_link(t('v.layouts._header.nav_links.settings'))
    end
  end

  it "does not have signin link", conditions do
    within('header nav') do
      expect(page).to_not have_link(t('v.layouts._header.nav_links.sign_in'))
    end
  end
end

shared_examples expect_errors: 1 do
  it "is invalid and has 1 error" do
    expect(subject).to have_errors(1)
  end
end