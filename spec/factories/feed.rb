FactoryGirl.define do
  factory :feed do
    sequence(:name) { |n| "Example Feed #{n}" }
    sequence(:url) { |n| "http://www.example.org/feed/#{n}" }

    factory :feed_with_feed_items do
      transient do
        feed_item_count 5
        since nil
      end

      after(:create) do |feed, evaluator|
        create_list(:feed_item, evaluator.feed_item_count, feed: feed, since: evaluator.since)
      end
    end
  end
end
