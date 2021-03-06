namespace :db do
  desc 'Populate database with sample data'
  task populate: :environment do
    User.create!(
      first_name: 'Alexander',
      last_name: 'Makarenko',
      email: 'alexander.makarenko@zoho.com',
      password: 'qwerty',
      password_confirmation: 'qwerty',
      locale: :ru,
      admin: true
    )

    99.times do |n|
      first_name = Faker::Name.first_name
      last_name = Faker::Name.last_name
      email = ('a'..'z').to_a.shuffle.first(4).join + '_' + Faker::Internet.safe_email
      password = Faker::Internet.password(8, 14)

      unless User.exists?(email: email)
        User.create!(
          first_name: first_name,
          last_name: last_name,
          email: email,
          password: password,
          password_confirmation: password
        )
      end
    end
  end
end