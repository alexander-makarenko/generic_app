require 'rails_helper'

describe "Changing and deleting the profile photo." do
  let(:user) { FactoryGirl.create(:user, :email_confirmed) }
  let(:account_link) { t 'v.layouts._header.nav_links.settings' }
  let(:account_page_heading) { t 'v.users.show.heading' }
  let(:change_photo_link) { t 'v.avatars.change_link' }
  let(:submit_photo_button) { t 'v.avatars.submit_button' }
  let(:remove_photo_link) { t 'v.avatars.delete_link' }

  subject { page.find('.photo') }

  before do
    visit signin_path
    sign_in_as user
    click_link account_link
    within(subject) { click_link change_photo_link }
  end

  describe "Upload form." do
    context "When the user has JS enabled,", :js do
      describe "the form" do
        it "is toggled when the user clicks the respective link" do
          expect(subject).to have_selector('form', count: 1)
          within(subject) { click_link change_photo_link }
          expect(subject).to_not have_selector('form', count: 1)
        end

        it "has a text field" do
          expect(subject.find('form')).to have_selector("input[type='text']")
        end

        it "has a disabled upload button" do
          expect(subject.find_button(submit_photo_button)[:class]).to include('disabled')
        end
      end

      context "after the user selects a file, the form" do
        let(:file_name) { 'valid.jpg' }

        before do
          attach_photo(file_name)
        end

        it "shows the file name in the text field" do
          expect(subject.find("input[type='text']").value).to eq file_name
        end

        it "has the upload button enabled" do
          expect(subject.find_button(submit_photo_button)[:class]).to_not include('disabled')
        end
      end
    end
  end

  describe "Upload form submission." do
    before do
      within(subject) do
        attach_photo(file_name)
        click_button submit_photo_button
      end
    end

    shared_examples "every submission" do
      it "the text field is cleared" do
        expect(subject.find("input[type='text']").value).to be_empty
      end

      it "the upload button is disabled" do
        expect(subject.find_button(submit_photo_button)[:class]).to include('disabled')
      end
    end

    shared_examples "invalid submission" do
      it "the profile photo is not changed" do
        expect(page.find('#avatar')).to have_xpath("//img[contains(@src, 'missing.png')]")
      end

      it "validation errors are shown" do
        expect(page).to have_selector('.validation-errors')
      end
    end

    shared_examples "valid submission" do
      let(:photo_changed) { t 'c.avatars.changed' }

      it "the profile photo is changed" do
        expect(page.find('#avatar')).to have_xpath("//img[contains(@src, file_name)]")
      end

      it "an appropriate flash is shown" do
        expect(page).to have_flash :success, photo_changed
      end
    end

    context "When the user who currently has no photo" do
      context "submits an invalid file" do
        let(:file_name) { 'invalid.bmp' }

        context "and has JS disabled" do
          it "the page is reloaded" do
            expect(page).to have_selector 'h2', text: account_page_heading
          end

          include_examples "invalid submission"
        end

        context "and has JS enabled", :js do
          it "the page is not reloaded" do
            expect(subject).to have_selector('form', count: 1)
          end

          include_examples "every submission"
          include_examples "invalid submission"
        end
      end

      context "submits a valid file" do
        let(:file_name) { 'valid.jpg' }

        context "and has JS disabled" do
          it "the page is reloaded" do
            expect(page).to have_selector 'h2', text: account_page_heading
          end

          include_examples "valid submission"
        end

        context "and has JS enabled", :js do
          it "the page is not reloaded" do
            expect(subject).to have_selector('form', count: 1)
          end

          it "a delete link is added to the layout" do
            expect(subject).to have_button(remove_photo_link, count: 1)
          end

          include_examples "every submission"
          include_examples "valid submission"
        end
      end
    end

    context "When the user who has already uploaded a photo" do
      let(:user) { FactoryGirl.create(:user, :email_confirmed, :photo_uploaded) }

      context "submits a valid file" do
        context "and has JS enabled", :js do
          let(:file_name) { 'valid.jpg' }

          it "another delete link is not added to the layout" do
            expect(subject).to have_button(remove_photo_link, count: 1)
          end
        end
      end
    end
  end

  describe "Delete link." do
    context "When the user currently has no photo" do
      shared_examples "shared" do
        it "the delete link is not available" do
          expect(subject).to_not have_button remove_photo_link
        end
      end

      context "and has JS disabled" do
        include_examples "shared"
      end

      context "and has JS enabled", :js do
        include_examples "shared"
      end
    end

    context "When the user has already uploaded a photo" do
      let(:user) { FactoryGirl.create(:user, :email_confirmed, :photo_uploaded) }

      shared_examples "shared" do
        let(:photo_removed) { t 'c.avatars.deleted' }

        it "the delete link is removed from the layout" do
          expect(page.find('.photo')).to_not have_button remove_photo_link
        end

        it "the profile photo is changed to default" do
          expect(page.find('#avatar')).to have_xpath("//img[contains(@src, 'missing.png')]")
        end

        it "an appropriate flash is shown" do
          expect(page).to have_flash :success, photo_removed
        end
      end

      context "and has JS disabled," do
        context "after the user clicks the delete link," do
          before do
            within(subject) do
              click_button remove_photo_link
            end
          end

          it "the page is reloaded" do
            expect(page).to have_selector 'h2', text: account_page_heading
          end

          include_examples "shared"
        end
      end

      context "and has JS enabled,", :js do
        context "after the user clicks the delete link," do
          before do
            within(subject) do
              click_button remove_photo_link
            end
          end

          it "the page is not reloaded" do
            expect(subject).to have_selector('form', count: 1)
          end

          include_examples "shared"
        end

        context "after the user uploads an invalid photo," do
          let(:file_name) { 'invalid.bmp' }

          before do
            within(subject) do
              attach_photo(file_name)
              click_button submit_photo_button
            end
          end

          it "validation errors are removed when the user clicks the delete link" do
            expect(page).to have_selector('.validation-errors')
            click_button remove_photo_link
            expect(page).to_not have_selector('.validation-errors')
          end
        end
      end
    end
  end
end