FactoryGirl.define do

  factory :expense do
    
    association :user, factory: :user_regular

    amount { Faker::Commerce.price }
    for_timeday { Faker::Time.between(100.days.ago, 1.day.ago) }
    description { Faker::Lorem.sentence }
    comment Faker::Lorem.sentence

    trait :future_time do
      for_timeday { Faker::Time.forward(5, :all) }
    end

    factory :expense_future, traits: [:future_time]

  end

end