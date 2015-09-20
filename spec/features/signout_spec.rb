feature "Signout" do
  given(:user) { FactoryGirl.create(:user, locale: :ru) }
  given(:signin_link) { t 'v.layouts._header.nav_links.sign_in' }
  given(:signout_link) { t 'v.layouts._header.nav_links.sign_out' }

  background do
    visit signin_path
    sign_in_as user
    click_link signout_link
  end

  it "does not sign the user in" do
    expect(page).to have_link(signin_link).and have_no_link(signout_link)
  end

  it "redirects to the home page" do
    expect(current_path).to eq root_path
  end

  it "leaves the locale as the user had it set in their preferences" do
    expect(I18n.locale).to eq :ru
  end
end