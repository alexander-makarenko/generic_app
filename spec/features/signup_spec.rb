require 'rails_helper'

feature "Signup" do
  given(:user)         { FactoryGirl.build(:user) }
  given(:invalid_user) { FactoryGirl.build(:user, :invalid) }
  background { visit signup_path }

  include_examples "page has", h1: t('v.users.new.header')
  
  context "with invalid data" do
    before(hook: true) { sign_up_as(invalid_user) }

    it "does not save user" do
      expect { sign_up_as(invalid_user) }.to_not change(User, :count)
    end

    it "does not send activation link" do
      expect { sign_up_as(invalid_user) }.to_not change(deliveries, :count)
    end

    include_examples "page has", { h1: t('v.users.new.header') }, hook: true
    include_examples "page has validation errors", hook: true
  end

  context "with valid data" do
    before(hook: true) { sign_up_as(user) }

    it "saves user" do
      expect { sign_up_as(user) }.to change(User, :count).from(0).to(1)
    end

    it "sends activation link" do
      expect { sign_up_as(user) }.to change(deliveries, :count).from(0).to(1)
    end

    it "redirects to home page", hook: true do
      expect(current_path).to eq(root_path)
    end

    include_examples "shows flash", :notice, t(
      'c.users.create.flash.notice'), hook: true
  end
end