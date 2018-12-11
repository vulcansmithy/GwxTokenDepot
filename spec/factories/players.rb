FactoryBot.define do
  factory :player do
    first_name = Faker::Name.first_name 
    last_name  = Faker::Name.last_name

    first_name { first_name }
    last_name  { last_name  }
    email      { "#{first_name}.#{last_name}@player.com".downcase }
  end
end
