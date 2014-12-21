require "rails_helper"

describe UserMailer, :type => :mailer do
  let(:user) { FactoryGirl.create(:user) }

  describe "#account_activation" do
    let(:mail) { UserMailer.activation(user) }

    it "renders the headers" do
      expect(mail.subject).to eq('Account activation')
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(['noreply@example.com'])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match(/activate\/(.+)\?e=(.+)/i)
    end
  end

  describe "#password_reset" do
    let(:mail) { UserMailer.password_reset(user) }

    it "renders the headers" do
      expect(mail.subject).to eq('Password reset')
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(['noreply@example.com'])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match(/recover\/(.+)\?e=(.+)/i)
    end
  end
end
