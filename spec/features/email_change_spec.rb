require 'rails_helper'

feature "Email change page" do
  given(:user) { FactoryGirl.create(:user, :email_confirmed) }
  # background do
  #   visit signin_path
  #   sign_in_as(user)
  #   click_link t('v.layouts._header.nav_links.settings')
  #   click_link t('v.users.show.email_change')
  # end

  # it "has proper heading" do
  #   expect(page).to have_selector 'h2', text: t('v.email_changes.new.heading')
  # end

  # it "has user email pre-filled" do
  #   expect(page.find('#email').value).to eq(user.email)
  # end

  # context "on submitting invalid data" do
  #   background { change_email_of(user, to: 'invalid@email') }
  # end

  #   it "does not update user's email" do
  #     expect(user.email).to eql(user.reload.email)
  #   end

  #   it "does not send email confirmation link" do
  #     expect(deliveries.count).to eq(1)
  #   end

  #   it "re-renders page" do
  #     expect(page).to have_selector 'h2', text: t('v.email_changes.new.heading')
  #   end

  #   it "shows validation errors" do
  #     expect(page).to have_selector('.validation-errors')
        # within('.validation-errors') do
        #   expect(page).to have_content(/#{t('activerecord.attributes.user.email')}/i)          
        # end
  #   end
  # end

  # context "on submitting valid data" do
  #   background { change_email_of(user, to: 'valid.new@email.com') }

  #   it "updates user's email" do
  #     expect(user.email).to_not eql(user.reload.email)
  #   end

  #   it "sends email confirmation link" do
  #     expect(deliveries.count).to eq(1)
  #   end

  #   it "redirects to profile page of current user" do
  #     expect(current_path).to match(account_path)
  #   end

  #   it "displays flash" do
  #     expect(page).to have_flash :success, t('c.email_changes.create.success')
  #   end
  # end

  # context "when cancelled" do
  #   background { click_link t('v.email_changes.new.cancel') }

  #   it "does not change user's email" do
  #     expect(user.email).to eql(user.reload.email)
  #   end

  #   it "shows profile page of current user" do
  #     expect(current_path).to match(account_path)
  #   end
  # end
end