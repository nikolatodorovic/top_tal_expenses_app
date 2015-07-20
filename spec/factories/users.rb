FactoryGirl.define do

  factory :user do

    email { Faker::Internet.email }
    password "password"
    id_role 1

    trait :has_name do
      first_name { Faker::Name.first_name }
      last_name { Faker::Name.last_name }
    end

    trait :regular do
      id_role 1
    end

    trait :admin do
      id_role 2
    end

    trait :manager do
      id_role 3
    end

    factory :user_regular, traits: [:has_name, :regular]
    factory :user_admin, traits: [:has_name, :admin]
    factory :user_manager, traits: [:has_name, :manager]

  end

end