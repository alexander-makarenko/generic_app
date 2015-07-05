require 'rails_helper'

feature "Password change page" do
  given(:user) { FactoryGirl.create(:user, :email_confirmed) }
  background do
    visit signin_path
    sign_in_as(user)
    click_link t('v.layouts._header.nav_links.settings')
    click_link t('v.users.show.password_change')
  end

  specify "has proper header" do
    expect(page).to have_selector 'h2', text: t('v.password_changes.new.header')
  end

  context "on submitting invalid data" do
    background do
      change_password_of(user, current_password: 'incorrect', new_password: ' ')
    end

    it "does not change user password" do
      expect(user.password_digest).to eql(user.reload.password_digest)
    end

    it "re-renders page" do
      expect(page).to have_selector 'h2', text: t('v.password_changes.new.header')
    end

    it "shows validation errors" do
      expect(page).to have_selector('.validation-errors')
    end
  end

  context "on submitting valid data" do
    given(:new_password) { 'qwerty123' }

    background do
      change_password_of(user,
        current_password: user.password,
        new_password:     new_password,
        confirmation:     new_password)
    end

    it "updates user's password" do
      expect(user.password_digest).to_not eql(user.reload.password_digest)
    end

    it "redirects to profile page of current user" do
      expect(current_path).to match(account_path)
    end

    it "displays flash" do
      expect(page).to have_flash :success, t('c.password_changes.create.success')
    end
  end

  context "when cancelled" do
    background { click_link t('v.password_changes.new.cancel') }

    it "does not change user password" do
      expect(user.password_digest).to eql(user.reload.password_digest)
    end

    it "shows profile page of current user" do
      expect(current_path).to match(account_path)
    end
  end
end