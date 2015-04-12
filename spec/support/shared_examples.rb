module Capybara
  class Session
    def has_flash?(type, contents)
      has_selector?("div.alert-#{type.to_s}", text: contents)
    end
  end
end

# add convenience method for I18n.t
def t(string, options={})
  I18n.t(string, options)
end

signin_link = t('v.layouts._header.nav_links.sign_in')
signout_link = t('v.layouts._header.nav_links.sign_out')
settings_link = t('v.layouts._header.nav_links.settings')

shared_examples "user is not signed in" do |conditions={}|
  it "has signin link", conditions do
    within('header nav') { expect(page).to have_link(signin_link) }
  end
  
  it "does not have signout link", conditions do
    within('header nav') do
      expect(page).to_not have_link(signout_link)
      expect(page).to_not have_link(settings_link)
    end
  end
end

shared_examples "user is signed in" do |conditions={}|
  it "has signout link", conditions do
    within('header nav') do
      expect(page).to have_link(settings_link)
      expect(page).to have_link(signout_link)
    end
  end

  it "does not have signin link", conditions do
    within('header nav') { expect(page).to_not have_link(signin_link) }
  end
end

shared_examples "is invalid and has errors" do |count, conditions={}|
  count_message = count == 1 ? 'an error' : "#{count} errors"
  specify %Q|is invalid and has #{count_message}|, conditions do
    expect(subject).to be_invalid
    expect(subject.errors.count).to eq(count)
  end
end

shared_examples "page has validation errors" do |conditions={}|
  specify "page has validation errors", conditions do
    expect(page).to have_selector("div.validation-errors")
  end
end

shared_examples "page has" do |options, conditions={}|
  options.each do |key, value|
    specify %Q|page has css "#{key}" with "#{value}"|, conditions do
      expect(page).to have_selector(key.to_s, text: value)
    end
  end
end