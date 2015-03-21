FactoryGirl.define do

  factory :user do
    sequence(:first_name) { Faker::Name.first_name }
    sequence(:last_name)  { Faker::Name.last_name }
    sequence(:email)      { Faker::Internet.safe_email }
    password              { Faker::Internet.password(8, 14) }
    password_confirmation { password }

    trait :invalid do
      first_name ''
      last_name  ''
      email      'invalid'
      password   { Faker::Internet.password(4) }
    end
    
    trait :activated do
      activated true
      activated_at Time.zone.now
    end

    # trait :email_not_confirmed_in_time do
    #   email_confirmation_sent_at { 3.days.ago }
    # end
  end
end