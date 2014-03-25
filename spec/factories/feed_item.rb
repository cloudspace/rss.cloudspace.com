FactoryGirl.define do
  factory :feed_item do
    sequence(:title) { |n| "Example Title #{n}" }
    sequence(:url) { |n| "http://www.example.org/feed_item/#{n}" }
    feed
    processed { true }
  end
end
