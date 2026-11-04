FactoryBot.define do
  factory :client do
    association :organization

    sequence(:name) { |n| "Cliente #{n}" }
    sequence(:email) { |n| "cliente#{n}@example.com" }
    phone { "11999999999" }
    status { "active" }
  end
end