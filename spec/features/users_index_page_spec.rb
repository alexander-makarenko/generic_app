require 'rails_helper'

describe "Users index page" do
  let(:admin) { FactoryGirl.create(:user, :admin) }
  let(:default_per_page) { WillPaginate.per_page }
  let(:heading) { t 'v.users.index.heading' }

  before do
    FactoryGirl.create_list(:user, default_per_page)
    visit signin_path
    sign_in_as admin
    visit users_path
  end

  it "has a proper heading" do
    expect(page).to have_selector 'h2', text: heading
  end

  it "has a search field" do
    expect(page).to have_selector('.search')
  end

  it "lists all users" do
    User.limit(3).each do |user|
      expect(page).to have_content(user.name).and have_content(user.email)
    end
  end

  context "when JS is enabled", :js do
    def scroll_to_bottom
      page.execute_script('window.scrollTo(0,100000)')
    end

    describe "as the page is scrolled down" do
      it "loads more users" do
        expect(User.count).to be > default_per_page
        expect(page).to have_selector('#users li', count: default_per_page)
        scroll_to_bottom
        expect(page).to have_selector('#users li', count: User.count)
      end

      it "shows a 'loading...' message while more data is being fetched" do
        scroll_to_bottom
        expect(page).to have_selector('.ajax-in-progress')
        expect(page).to_not have_selector('.ajax-in-progress')
      end

      it "does not have pagination at the bottom of the page" do
        scroll_to_bottom
        expect(page).to_not have_selector('.pagination')
      end

    end
  end

  context "when JS is disabled" do
    it "has pagination" do
      expect(page).to have_selector('.pagination')
    end
  end
end