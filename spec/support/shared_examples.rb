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


shared_examples "user is not signed in" do |conditions={}|
  it "has signin link", conditions do
    within('header nav') { expect(page).to have_link(t('v.layouts._header.nav_links.sign_in')) }
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
      expect(page).to have_link(t('v.layouts._header.nav_links.settings'))
      expect(page).to have_link(t('v.layouts._header.nav_links.sign_out'))
    end
  end

  it "does not have signin link", conditions do
    within('header nav') { expect(page).to_not have_link(t('v.layouts._header.nav_links.sign_in')) }
  end
end

shared_examples "is invalid and has errors" do |count, conditions={}|
  count_message = count == 1 ? 'an error' : "#{count} errors"  
  specify %Q|is invalid and has #{count_message}|, conditions do
    expect(subject).to be_invalid
    expect(subject.errors.count).to eq(count)
  end
end