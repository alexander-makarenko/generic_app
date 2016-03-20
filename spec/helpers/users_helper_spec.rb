require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the UsersHelper. For example:

describe UsersHelper do
  describe "#humanize_boolean" do
    it "converts a boolen true to a translated yes" do
      expect(helper.humanize_boolean(true)).to eq(t('h.users_helper.yes'))
    end

    it "converts a boolen false to a translated no" do
      expect(helper.humanize_boolean(false)).to eq(t('h.users_helper.no'))
    end
  end

  describe "#humanize_locale" do
    let(:user) { FactoryGirl.build(:user, locale: :ru) }

    it "returns the translated name of the given locale" do
      expect(helper.humanize_locale(user.locale)).to eq(t('v.shared._locale_selector.ru'))
    end
  end

  describe "#last_seen_time_ago_in_words" do
    subject { helper.last_seen_time_ago_in_words(user) }

    context "when the user's last_seen_at time is not set" do
      let(:user) { FactoryGirl.build(:user) }

      it "returns a '—'" do
        expect(subject).to match /\A—\z/i
      end
    end

    context "when the user's last_seen_at time is set" do
      let(:user) { FactoryGirl.build(:user, last_seen_at: 1.day.ago) }

      it "returns a string that ends with the localized word 'ago'" do
        expect(subject).to match /#{t('h.users_helper.ago')}\z/i
      end
    end
  end
end