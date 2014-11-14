FactoryGirl.define do
  factory :setting do
    factory :min do
      name 'backoff_min'
      value 2
    end

    factory :max do
      name 'backoff_max'
      value 6
    end
  end
end
