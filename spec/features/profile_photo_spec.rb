require 'rails_helper'

feature "Profile photo change" do
  given(:user) { FactoryGirl.create(:user, :email_confirmed) }
  given(:account_link) { t 'v.layouts._header.nav_links.settings' }
  given(:account_page_heading) { t 'v.users.show.heading' }
  given(:avatar_change_link) { t 'v.users.show.avatar_change'}
  given(:avatar_submit_button) { t('v.users.show.avatar_submit') }

  background do
    visit signin_path
    sign_in_as user
    click_link account_link
  end

  def attach_photo(file_name)
    # Change the file upload button's overflow property so that capybara-webkit
    # could click on it.
    if Capybara.current_driver == Capybara.javascript_driver
      execute_script("$('.btn-file').css('overflow', 'visible')")
    end

    attach_file('file-select', 'spec/support/uploads/' + file_name)
  end

  subject { page.find('#avatar-selector') }

  feature "form" do
    context "when JS is disabled" do
      # The text field initially has a CSS class "hidden" that is then removed
      # using JavaScript. The following spec doesn't work because the Rack::Test
      # driver completely ignores CSS and JavaScript. A possible workaround
      # would be to switch the JS driver to Selenium and then disable JS.

      # it "does not have a text field" do
      #   expect(subject).to_not have_selector('input[type=text]')
      # end

      it "has an upload button" do
        expect(subject).to have_button avatar_submit_button
      end
    end

    context "when JS is enabled", js: true do
      background { click_link avatar_change_link }

      it "has a text field" do
        expect(subject).to have_field('file-name')
      end

      it "has a disabled upload button" do
        expect(subject.find_button(avatar_submit_button)[:class]).to include('disabled')
      end

      context "when a file is selected" do
        given(:file_name) { 'avatar.jpeg' }

        background { attach_photo file_name }

        it "shows the file name in the text field" do
          expect(subject.find_field('file-name').value).to eq file_name
        end

        it "enables the upload button" do
          expect(subject.find_button(avatar_submit_button)[:class]).to_not include('disabled')
        end
      end
    end
  
    describe "on submission" do
      background(js: false) do
        attach_photo(file_name)
        click_button avatar_submit_button
      end

      background(js: true) do
        click_link avatar_change_link
        attach_photo(file_name)
        click_button avatar_submit_button
      end

      shared_examples "submission" do
        it "clears the text field value" do          
          expect(subject.find_field('file-name').value).to be_empty
        end

        it "disables the upload button" do
          expect(subject.find_button(avatar_submit_button)[:class]).to include('disabled')
        end
      end

      shared_examples "invalid submission" do
        it "does not change the profile photo" do
          expect(page.find('#avatar')[:src]).to match 'missing.png'
        end

        it "shows validation errors" do
          expect(page).to have_selector '.validation-errors'
        end
      end

      shared_examples "valid submission" do
        given(:avatar_changed) { t 'c.avatars.avatar_changed' }

        it "changes the profile photo" do
          expect(page.find('#avatar')).to have_xpath("//img[contains(@src, file_name)]")
        end

        it "shows an appropriate flash" do
          expect(page).to have_flash :success, avatar_changed
        end
      end

      context "of an invalid file" do
        given(:file_name) { 'avatar.bmp' }

        context "when JS is disabled", js: false do
          it "reloads the page" do
            expect(page).to have_selector 'h2', text: account_page_heading
          end
          
          include_examples "invalid submission"
        end

        context "when JS is enabled", js: true do
          it "does not reload the page" do
            expect(page).to have_selector '#avatar-selector'
          end

          include_examples "submission"
          include_examples "invalid submission"
        end
      end

      context "of a valid file" do
        given(:file_name) { 'avatar.jpeg' }

        context "when JS is disabled", js: false do
          it "reloads the page" do
            expect(page).to have_selector 'h2', text: account_page_heading
          end

          include_examples "valid submission"
        end

        context "when JS is enabled", js: true do
          it "does not reload the page" do
            expect(page).to have_selector '#avatar-selector'
          end

          include_examples "submission"
          include_examples "valid submission"
        end
      end
    end
  end
end