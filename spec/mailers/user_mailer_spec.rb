require "rails_helper"

describe UserMailer, :type => :mailer do
  let(:user) { FactoryGirl.create(:user) }

  describe "#activation" do
    let(:mail) { UserMailer.activation(user) }

    it "renders the headers" do
      expect(mail.subject).to eq(t('m.user_mailer.activation.subject'))
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(['noreply@example.com'])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match(/activate\/(.+)/i)
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
      expect(mail.body.encoded).to match(/recover\/(.+)/i)
    end
  end
end