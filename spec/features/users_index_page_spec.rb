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

  it "has a search form" do
    expect(page).to have_selector('form.search')
  end

  describe "when invalid sort parameters are provided in the url" do
    it "does not raise an exception" do
      expect { visit users_path(sort: :invalid, direction: :invalid) }.to_not raise_error
    end
  end

  describe "has a table that" do
    let(:ids) do
      all('#users tbody td:first-child').map { |id| id.text.to_i }
    end

    def sort_by_id_link
      find('#users thead a', text: t('v.users.index.th_id'))
    end

    it "lists all users" do
      User.limit(3).each do |user|
        expect(page).to have_selector('#users tbody tr', text: user.email)
      end
    end

    it "has links for sorting in the header" do
      all('#users thead th').each do |header_cell|
        within header_cell do
          expect(page).to have_selector('a')
        end
      end
    end

    it "is by default sorted by user id in ascending order" do
      expect(ids).to eq(ids.sort)
    end

    it "has a sort order triangle in only a single column" do
      within '#users thead' do
        expect(page).to have_selector('.asc', count: 1).or have_selector('.desc', count: 1)
      end
    end

    describe "when the user clicks the id column" do
      before { sort_by_id_link.click }

      context "once" do
        it "gets sorted by user id in descending order" do
          expect(ids).to eq(ids.sort.reverse)
        end

        it "has a down-pointing triangle in the id column" do
          expect(sort_by_id_link[:class]).to include('desc')
        end
      end

      context "twice" do
        before { sort_by_id_link.click }

        it "gets sorted by user id in ascending order" do
          expect(ids).to eq(ids.sort)
        end

        it "has an up-pointing triangle in the id column" do
          expect(sort_by_id_link[:class]).to include('asc')
        end
      end
    end
  end

  context "when JS is enabled", :js do
    def scroll_to_bottom
      execute_script('window.scrollTo(0,100000)')
    end

    describe "as the page is scrolled down" do
      it "loads more users" do
        expect(User.count).to be > default_per_page
        expect(page).to have_selector('#users tbody tr', count: default_per_page)
        scroll_to_bottom
        expect(page).to have_selector('#users tbody tr', count: User.count)
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