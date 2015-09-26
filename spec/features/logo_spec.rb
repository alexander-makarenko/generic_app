require 'rails_helper'

feature "Logo" do
  it "links to the home page" do
    visit signin_path
    find('#logo').click

    expect(current_path).to eq root_path
  end
end