require "rails_helper"

describe UserMailer, :type => :mailer do
  let(:user) { FactoryGirl.create(:user) }

  describe "#email_confirmation" do
    let(:mail) { UserMailer.email_confirmation(user) }

    it "renders the headers" do
      expect(mail.subject).to eq(t('m.user_mailer.email_confirmation.subject'))
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(['noreply@example.com'])
    end

    it "renders the body" do      
      expect(mail.body.encoded).to match(/#{I18n.locale}(\/.*)+\/confirm\/(.+)/i)
    end
  end

  describe "#password_reset" do
    let(:mail) { UserMailer.password_reset(user) }

    it "renders the headers" do
      expect(mail.subject).to eq(t('m.user_mailer.password_reset.subject'))
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(['noreply@example.com'])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match(/#{I18n.locale}(\/.*)+\/recover\/(.+)/i)
    end
  end
end