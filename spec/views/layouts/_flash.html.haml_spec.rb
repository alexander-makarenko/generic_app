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

  context "when the flash has" do
    context "a key that references a string" do
      before { flash[:success] = 'foo' }

      it "renders the string" do
        expect(subject).to match(/success/).and match(/foo/)
      end
    end

    context "a key that references an array" do
      before { flash[:success] = ['foo', 'bar', 'baz'] }

      it "renders its first 2 elements" do
        expect(subject).to match(/success/).and match(/foo/).and match(/bar/)
        expect(subject).to_not match(/baz/)
      end
    end

    context "multiple keys that reference either a string or a 2-element array" do
      before { flash[:success], flash[:info] = 'foo', ['bar', 'baz'] }

      it "renders both the string and the array" do
        expect(subject).to match(/success/).and match(/info/)
        expect(subject).to match(/foo/).and match(/bar/).and match(/baz/)
      end
    end

    context "a key that references neither a string nor an array" do
      before { flash[:danger], flash[:info] = {}, 'foo' }

      it "does not render it" do
        expect(subject).to match(/info/).and match(/foo/)
        expect(subject).to_not match(/danger/)
      end
    end
  end
end