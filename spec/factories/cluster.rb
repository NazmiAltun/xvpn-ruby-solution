FactoryBot.define do
  factory :cluster do
    name { Faker::Address.city }
    subdomain { Faker::Internet.domain_name }
  end
end
