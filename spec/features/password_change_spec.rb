require 'rails_helper'

feature "Password change page" do
  given(:user) { FactoryGirl.create(:user, :activated) }
  background do
    visit signin_path
    sign_in_as(user)
    #=======================================================
    # replace with "visit settings_path(user)"
    # after removing the "default_url_options" method from application_controller
    visit settings_path(id: user.id)
    #=======================================================
    click_link t('v.users.edit.change_password')
  end

  specify "has proper header" do
    expect(page).to have_selector 'h2', text: t('v.password_changes.new.header')
  end

  context "on submission invalid data" do
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

    it "redirects to current user edit page" do
      #=======================================================
      # replace with "settings_path(user)"
      # after removing the "default_url_options" method from application_controller
      expect(current_path).to match(settings_path(id: user.id))
      #=======================================================
    end

    it "displays flash" do
      expect(page).to have_flash :success, t('c.password_changes.create.flash.success')
    end
  end

  context "when cancelled" do
    background { click_link t('v.password_changes.new.cancel') }

    it "does not change user password" do
      expect(user.password_digest).to eql(user.reload.password_digest)
    end

    it "shows current user edit page" do
      expect(current_path).to match(settings_path(id: user.id))
    end
  end
end