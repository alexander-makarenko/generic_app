FactoryGirl.define do
  factory :user do
    sequence(:name)  { |n| "Person #{n+1}"}
    sequence(:email) { |n| "person_#{n+1}@example.com" }
    password { Faker::Internet.password(8, 14) }
    password_confirmation { password }
  end
end