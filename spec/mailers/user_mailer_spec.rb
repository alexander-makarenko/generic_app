require "rails_helper"

describe UserMailer do
  let(:default_from) { ['noreply@example.com'] }
  let(:user) { FactoryGirl.create(:user) }

  describe "#welcome" do
    let(:mail) { UserMailer.welcome(user) }

    it "renders the headers" do
      expect(mail).to have_attributes(
        subject: t('m.user_mailer.welcome.subject'),
        to: [user.email],
        from: default_from
      )
    end

    it "renders the body" do
      expect(mail.body.encoded).to match t('v.user_mailer.welcome')
    end
  end

  describe "#email_confirmation" do
    let(:mail) { UserMailer.email_confirmation(user) }

    it "renders the headers" do
      expect(mail).to have_attributes(
        subject: t('m.user_mailer.email_confirmation.subject'),
        to: [user.email],
        from: default_from
      )
    end

    it "renders the body" do
      email_confirmation_link_regex = /\/confirm\/(.+)/i
      expect(mail.body.encoded).to match email_confirmation_link_regex
    end
  end

  describe "#email_change_confirmation" do
    let(:mail) { UserMailer.email_change_confirmation(user) }

    it "renders the headers" do
      expect(mail).to have_attributes(
        subject: t('m.user_mailer.email_change_confirmation.subject'),
        to: [user.email],
        from: default_from
      )
    end

    it "renders the body" do
      email_confirmation_link_regex = /\/confirm\/(.+)/i
      expect(mail.body.encoded).to match email_confirmation_link_regex
    end
  end

  describe "#email_changed_notice" do
    let(:mail) { UserMailer.email_changed_notice(user) }
    before { user.update_attribute(:old_email, 'original_email@example.com') }

    it "renders the headers" do
      expect(mail).to have_attributes(
        subject: t('m.user_mailer.email_changed_notice.subject'),
        to: [user.old_email],
        from: default_from
      )
    end

    it "renders the body" do
      expect(mail.body.encoded).to match t('v.user_mailer.email_changed_notice')
    end
  end

  describe "#password_reset" do
    let(:mail) { UserMailer.password_reset(user) }

    it "renders the headers" do
      expect(mail).to have_attributes(
        subject: t('m.user_mailer.password_reset.subject'),
        to: [user.email],
        from: default_from
      )
    end

    it "renders the body" do
      password_reset_link_regex = /\/recover\/(.+)/i
      expect(mail.body.encoded).to match password_reset_link_regex
    end
  end
end