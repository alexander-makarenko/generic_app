require 'rails_helper'

shared_examples "sortability" do
  feature "sort order indicator" do
    scenario "an up-pointing triangle in the respective column denotes ascending order" do
      within('thead tr.sorting') do
        expect(page).to have_selector('a.asc', count: 1, text: id)
      end
    end

    scenario "a down-pointing triangle in the respective column denotes descending order" do
      page.find('thead tr.sorting').find_link(id).click
      within('thead tr.sorting') do
        expect(page).to have_selector('a.desc', count: 1, text: id)
      end
    end
  end

  feature "sort order reversal" do
    background do
      page.find('thead tr.sorting').find_link(id).click
    end
    
    scenario "occurs when the user clicks the column by which the table is currently sorted" do
      within('tbody') do
        User.limit(3).each do |user|
          expect(page.find("tr:nth-child(#{user.id})")).to have_content(User.count - (user.id - 1))
        end
      end
    end
  end

  feature "switching of the sort column" do
    given(:sorted_emails) { User.pluck(:email).sort }

    background do
      page.find('thead tr.sorting').find_link(email).click
    end

    scenario "occurs when the user clicks a column by which the table is not currently sorted" do
      within('tbody') do
        User.limit(3).each do |user|
          expect(page.find("tr:nth-child(#{user.id})")).to have_content(sorted_emails[user.id - 1])
        end
      end
    end
  end
end

feature "Users index" do
  given(:admin) { FactoryGirl.create(:user, :admin) }
  given(:pagination_limit) { WillPaginate.per_page }
  given(:columns_in_table) { 5 }
  given(:id)    { t('v.users.index.th_id') }
  given(:email) { t('v.users.index.th_email') }

  background do
    FactoryGirl.create_list(:user, pagination_limit)
    visit signin_path
    sign_in_as admin
  end

  context "JS disabled" do
    feature "page" do
      given(:heading) { t('v.users.index.heading') }

      scenario "has proper appearance" do
        visit users_path
        expect(page).to have_selector('h2', text: heading)
        expect(page).to have_selector('thead tr.sorting a', count: columns_in_table)
        expect(page.find('thead tr#users_search')[:class]).to include('hidden')
        expect(page).to have_selector('tbody tr', count: pagination_limit)
      end

      scenario "opens without an exception when invalid parameters are provided in the url" do
        expect { visit users_path(sort: :invalid, direction: :invalid) }.to_not raise_error
      end
    end

    feature "pagination" do
      scenario "is not triggered when the number of users is lower than the pagination limit" do
        User.second.destroy
        visit users_path
        expect(User.count).to be <= pagination_limit
        expect(page).to_not have_selector('.pagination')
      end

      scenario "is triggered when the number of users exceeds the pagination limit" do
        visit users_path
        expect(User.count).to be > pagination_limit
        expect(page).to have_selector('.pagination')
      end
    end  

    feature "sorting" do
      background do
        visit users_path
      end

      scenario "ascending sort order by id is the default" do
        within('tbody') do
          User.limit(3).each do |user|
            expect(page.find("tr:nth-child(#{user.id})")).to have_content(user.id)
          end
        end
      end

      it_has_behavior "sortability"
    end
  end

  context "JS enabled", :js do
    background do
      visit users_path
    end

    feature "page" do      
      scenario "has proper appearance" do
        within('thead') do
          expect(page.find('tr#users_search')[:class]).to_not include('hidden')
          expect(page).to have_selector('input', count: columns_in_table)
        end
      end

      scenario "clicking a row in the table redirects to the respective user's show page" do
        user = User.third
        page.find('tbody tr', text: user.email).click
        expect(page).to have_selector('#userInfo', text: user.email)
      end
    end

    feature "datepicker" do
      scenario "appears when the user clicks the 'registered on' search field" do
        expect(page).to_not have_selector('.datepicker')
        page.find_field('search[created_at]').click
        expect(page).to have_selector('.datepicker')
      end
    end

    feature "endless scrolling" do
      def scroll_to_bottom
        execute_script('window.scrollTo(0,100000)')
      end

      scenario "all users are loaded when the page is scrolled to the bottom" do
        expect(User.count).to be > pagination_limit
        expect(page).to have_selector('tbody tr', count: pagination_limit)
        scroll_to_bottom
        expect(page).to have_selector('tbody tr', count: User.count)
      end

      scenario "newly loaded rows are clickable and redirect to the respective user's show page" do
        user = User.last
        expect(page).to_not have_selector('tbody tr', text: user.email)
        scroll_to_bottom
        page.find('tbody tr', text: user.email).click
        expect(page).to have_selector('#userInfo', text: user.email)
      end

      scenario "pagination links are not shown once all users are loaded" do
        scroll_to_bottom
        expect(page).to have_no_selector('ul.pagination')
      end

      scenario "while more data is being fetched, a spinner with a relevant message is shown" do
        scroll_to_bottom
        expect(page).to have_selector('.loading')
        expect(page).to have_no_selector('.loading')
      end

      scenario "while more data is being fetched, pagination links get hidden" do
        scroll_to_bottom
        expect(page).to have_no_selector('div.pagination')
        expect(page).to have_selector('div.pagination')
      end

      scenario "after a search, only users that matched the query are loaded when the page is scrolled to the bottom" do
        User.update_all(last_name: 'foobar')
        FactoryGirl.create(:user, last_name: 'barbaz')
        visit current_path
        find_user(last_name: 'foobar')
        wait_for_ajax
        scroll_to_bottom
        wait_for_ajax
        within('tbody') do
          expect(page).to have_selector('tr', text: 'foobar', count: User.count - 1)
          expect(page).to_not have_selector('tr', text: 'barbaz')
        end
      end
    end

    feature "sorting" do
      it_has_behavior "sortability"

      scenario "does not affect the search results" do
        searched_user = User.last
        find_user(id: searched_user.id)
        wait_for_ajax
        within('thead tr.sorting') do
          page.find_link(email).click
          expect(page).to have_selector('a.asc', text: email)
        end
        within('tbody') do
          expect(page).to have_selector('tr', count: 1).and have_selector('tr', text: searched_user.id)
        end
      end
    end

    feature "search" do
      given(:searched_user) { User.last }

      scenario "when some users match the search query, they are listed" do
        find_user(id: searched_user.id)
        wait_for_ajax
        within('tbody') do
          expect(page).to have_selector('tr', count: 1).and have_selector('tr', text: searched_user.id)
        end
      end

      scenario "when no users match the search query, no users are listed" do
        find_user(email: 'nonexistent')
        wait_for_ajax
        within('tbody') do
          expect(page).to have_no_selector('tr')
        end
      end

      scenario "doing a search does not affect the sorting settings" do
        visit users_path(sort: :email, direction: :desc)
        find_user(id: searched_user.id)
        wait_for_ajax
        within('tbody') do
          expect(page).to have_selector('tr', count: 1).and have_selector('tr', text: searched_user.id)
        end
        within('thead tr.sorting') do
          expect(page).to have_selector('a.desc', text: email)
        end
      end

      scenario "the query persists in the search fields after its submission and table sorting" do
        query = User.last.email
        find_user(email: query)
        wait_for_ajax
        page.find('thead tr.sorting').find_link(email).click
        within('thead') do
          expect(page.find('tr.sorting')).to have_selector('a.asc', text: email)
          expect(page.find('tr#users_search')).to have_selector("input[value='#{query}']")
        end
      end
    end
  end
end