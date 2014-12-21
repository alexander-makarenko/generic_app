namespace :db do
  desc "Populate database with sample data"
  task populate: :environment do
    User.create!(name: "Test",
                 email: "alexander.makarenko@zoho.com",
                 password: "qwerty",
                 password_confirmation: "qwerty")
  end
end