require "rails_helper"

describe "layouts/_flash" do
  subject do
    render
    rendered
  end

  context "when the flash is empty" do
    it "renders nothing" do
      expect(subject).to be_empty
    end
  end

  context "when the flash is not empty" do    
    before { flash[:success] = 'foo >' }

    it "renders its value" do
      expect(subject).to match(/success/).and match(/foo/)
    end

    it "treats the string as HTML-safe" do
      expect(subject).to match(/foo >/)
    end
  end

  context "when the flash contains multiple keys" do
    before { flash[:success], flash[:info] = 'foo', 'bar' }

    it "renders them all" do
      expect(subject).to match(/success/).and match(/info/)
      expect(subject).to match(/foo/).and match(/bar/)
    end
  end
end