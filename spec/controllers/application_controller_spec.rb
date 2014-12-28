require 'rails_helper'

describe ApplicationController do
  controller do
    def index
      render nothing: true # do nothing other than invoke filters
    end
  end

  describe "#set_locale" do
    it "sets locale to that given in URL" do
      get :index, locale: :ru
      expect(I18n.locale).to eq(:ru)
    end

    it "sets locale to default when none is given in URL" do
      get :index
      expect(I18n.locale).to eq(:en)
    end
  end
end