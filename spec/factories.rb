FactoryGirl.define do

  factory :user do
    sequence(:first_name) { Faker::Name.first_name }
    sequence(:last_name)  { Faker::Name.last_name }
    sequence(:email)      { ('a'..'z').to_a.shuffle.first(4).join + '_' + Faker::Internet.safe_email }
    password              { Faker::Internet.password(8, 14) }
    password_confirmation { password }

    trait :invalid do
      first_name ''
      last_name  ''
      email      'invalid'
      password   { Faker::Internet.password(4) }
    end

    trait :admin do
      admin true
    end
    
    trait :email_confirmed do
      email_confirmed    true
      email_confirmed_at Time.zone.now
    end

    trait :email_confirmation_sent do
      email_confirmation_sent_at 2.minutes.ago
    end

    trait :password_reset_sent do
      password_reset_sent_at 2.minutes.ago
    end

    trait :email_change_pending do
      old_email              Faker::Internet.safe_email
      old_email_confirmed    true
      old_email_confirmed_at 1.week.ago
    end

    trait :photo_uploaded do
      avatar { File.new("#{Rails.root}/spec/support/attachments/users/avatars/valid.jpg") }
    end
  end
end