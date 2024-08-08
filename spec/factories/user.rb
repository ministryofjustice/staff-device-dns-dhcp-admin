FactoryBot.define do
  factory :user do
    email { "test@example.com" }

    trait :editor do
      role { User.roles[:editor] }
    end

    trait :second_line_support do
      role { User.roles[:second_line_support] }
    end

    trait :viewer do
      role { User.roles[:viewer] }
    end
  end
end
