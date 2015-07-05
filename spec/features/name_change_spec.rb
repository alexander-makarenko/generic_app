require 'rails_helper'

feature "Name change page" do
  given(:user) { FactoryGirl.create(:user, :email_confirmed) }
  background do
    visit signin_path
    sign_in_as(user)
    click_link t('v.layouts._header.nav_links.settings')
    click_link t('v.users.show.name_change')
  end

  specify "has proper heading" do
    expect(page).to have_selector 'h2', text: t('v.name_changes.new.heading')
  end

  context "on submitting invalid data" do
    background { change_name_of user, to: [' ', 'LAST'] }

    it "does not change user's name" do
      expect(user.name).to eql(user.reload.name)
    end

    it "re-renders page" do
      expect(page).to have_selector 'h2', text: t('v.name_changes.new.heading')
    end

    it "shows validation errors" do
      expect(page).to have_selector('.validation-errors')
    end
  end

  context "on submitting valid data" do
    background { change_name_of user, to: ['First', 'L'] }

    it "updates user's name" do
      expect(user.name).to_not eql(user.reload.name)
    end

    it "redirects to profile page of current user" do
      expect(current_path).to match(account_path)
    end

    it "displays flash" do
      expect(page).to have_flash :success, t('c.name_changes.create.success')
    end
  end

  context "when cancelled" do
    background { click_link t('v.name_changes.new.cancel') }

    it "does not change user's name" do
      expect(user.name).to eql(user.reload.name)
    end

    it "shows profile page of current user" do
      expect(current_path).to match(account_path)
    end
  end
end