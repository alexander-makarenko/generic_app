require 'rails_helper'

# describe "Users index search." do
#   let(:user) { User.third }
#   let(:admin) { FactoryGirl.create(:user, :admin) }

#   before do
#     FactoryGirl.create_list(:user, 5)
#     visit signin_path
#     sign_in_as admin
#     visit users_path
#   end

#   describe "When the search form is submitted" do
#     before do
#       find_user(search_query)
#     end

#     shared_examples "shared" do
#       specify "that user is listed" do
#         expect(page).to have_content(user.name).and have_content(user.email)
#         expect(page).to have_selector('#users li', count: 1)
#       end
#     end

#     context "and there is a user whose name matches the query" do
#       let(:search_query) { user.name[2..-2] }

#       include_examples "shared"
#     end

#     context "and there is a user whose email matches the query" do
#       let(:search_query) { user.email[3..-3] }

#       include_examples "shared"
#     end

#     # it "does something" do
#     #   puts User.count
#     #   puts User.first.name
#     #   puts User.first.name[3..-3]
#     #   puts User.first.email
#     #   expect(2).to_not eq(2)
#     # end
#   end
# end