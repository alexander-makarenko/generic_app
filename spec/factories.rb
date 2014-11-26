FactoryGirl.define do

  factory :user do
    sequence(:name)  { |n| "Person #{n+1}"}
    sequence(:email) { |n| "person_#{n+1}@example.com" }
    password { Faker::Internet.password(8, 14) }
    password_confirmation { password }

    trait :invalid do
      name ''
      email 'invalid'
    end
    
    trait :activated do
      activated true
      activated_at Time.zone.now
    end

    # trait :not_activated_in_time do
    #   activation_email_sent_at { 3.days.ago }
    # end
  end
end