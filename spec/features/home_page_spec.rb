require 'rails_helper'

feature "The home page", :js do
  background do
    visit root_path
  end

  feature "features" do
    given(:feature_heading) { find('.panel:first-child .panel-heading a') }

    scenario "have a right-pointing chevron icon in the description when collapsed" do
      expect(feature_heading).to have_selector('.glyphicon-chevron-right')
    end

    scenario "have a downward-pointing chevron icon in the description when expanded" do
      feature_heading.click
      expect(feature_heading).to have_selector('.glyphicon-chevron-down')
    end
  end
end