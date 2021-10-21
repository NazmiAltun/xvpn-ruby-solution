FactoryBot.define do
  factory :server do
    friendly_name { Faker::Internet.username }
    ip_string { Faker::Internet.ip_v4_address }
    cluster
  end
end
