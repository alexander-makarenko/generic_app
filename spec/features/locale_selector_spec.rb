require 'rails_helper'

feature "Locale selector" do
  background { visit root_path }
  
  english, russian = t [:en, :ru], scope: 'v.layouts._footer.locale'

  it "lists available locales" do
    [english, russian].each do |locale|
      expect(find('footer')).to have_content(locale)
    end
  end

  it "does not show link to current locale" do
    within('footer') do
      expect(page).to_not have_link english
      expect(page).to     have_link russian
    end

    within('footer') { click_link russian }

    within('footer') do
      expect(page).to     have_link english
      expect(page).to_not have_link russian
    end
  end

  it "switches locale when respective link is clicked" do
    expect(current_path).to eq localized_root_path(locale: :en)
    within('footer') { click_link russian }
    expect(current_path).to eq localized_root_path(locale: :ru)
  end
end