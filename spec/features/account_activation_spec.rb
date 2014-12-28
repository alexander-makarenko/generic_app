require 'rails_helper'

feature "Account activation" do
  given(:user) { FactoryGirl.build(:user) }
  given(:nonexistent_user) { FactoryGirl.build(:user) }
  background do
    visit signup_path
    sign_up_as(user)
  end

  feature "link" do
    context "with missing token" do
      # write this test after implementing Routing Error handler
      # (the user will probably see the 404 error)
    end

    context "with invalid token" do
      background { visit link(:activation, token: 'invalid') }

      it "redirects to home page" do
        expect(current_path).to eq(root_path)
      end

      include_examples "shows flash", :error, t(
        'c.account_activations.edit.flash.error.2', link: t(
          'c.account_activations.edit.flash.link'))
    end

    context "with missing encoded email" do
      background { visit link(:activation, encoded_email: :missing) }
      
      it "redirects to home page" do
        expect(current_path).to eq(root_path)
      end

      include_examples "shows flash", :error, t(
        'c.account_activations.edit.flash.error.2', link: t(
          'c.account_activations.edit.flash.link'))
    end

    context "with invalid encoded email" do
      # write this test after implementing BadRequest handler
      # (the user will probably be redirected somewhere)
    end

    context "that has expired" do
      background do
        persisted_user = User.find_by(email: user.email)
        persisted_user.update_attribute(:activation_email_sent_at, 1.week.ago)
        visit link(:activation)
      end

      it "redirects to home page" do
        expect(current_path).to eq(root_path)
      end
    
      include_examples "shows flash", :error, t(
        'c.account_activations.edit.flash.error.1', link: t(
          'c.account_activations.edit.flash.link'))
    end

    context "that is valid" do
      background { visit link(:activation) }

      it "redirects to signin page" do
        #=======================================================
        # replace with "expect(current_path).to eq(signin_path)" after
        # removing the "default_url_options" method from application_controller
        expect(current_path).to eq(signin_path(locale: 'en'))
        #=======================================================
      end        

      include_examples "shows flash", :success, t(
        'c.account_activations.edit.flash.success')
    end
  end

  feature "re-request" do
    background  do
      visit link(:activation, token: 'invalid')
      within('.flash') { click_link(t(
        'c.account_activations.edit.flash.link')) }
    end

    include_examples "page has", h1: t('v.account_activations.new.header')

    context "with invalid data" do
      background { rerequest_activation_email_as(nonexistent_user) }

      it "does not send activation link" do
        expect(deliveries.count).to eq(1)
      end

      include_examples "page has", h1: t('v.account_activations.new.header')

      include_examples "shows flash", :error, t(
        'c.account_activations.create.flash.error')
    end

    context "with valid data" do
      background { rerequest_activation_email_as(user) }

      it "sends activation link" do
        expect(deliveries.count).to eq(2)
      end

      it "redirects to home page" do
        expect(current_path).to eq(root_path)
      end

      include_examples "shows flash", :notice, t(
        'c.account_activations.create.flash.notice')
    end
  end
end