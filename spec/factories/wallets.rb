FactoryBot.define do
  factory :wallet do
    wallet_address { Faker::Bitcoin.testnet_address }
  end
end
