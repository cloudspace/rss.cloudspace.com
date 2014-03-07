FactoryGirl.define do
  sequence :name do |n|
    "Example Feed #{n}"
  end

  sequence :feed_url do |n|
    "http://www.example.org/feed/#{n}"
  end

  factory :feed do
    name
    feed_url

    factory :feed_with_feed_items do
      ignore do
        feed_items_count 5
      end

      after(:create) do |feed, evaluator|
        create_list(:feed_item, evaluator.feed_items_count, { feed: feed })
      end
    end
  end
end
