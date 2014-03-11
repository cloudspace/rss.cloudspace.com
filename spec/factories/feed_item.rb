FactoryGirl.define do
  sequence :title do |n|
    "Example Title #{n}"
  end

  sequence :url do |n|
    "http://www.example.org/articles/#{n}"
  end

  factory :feed_item do
    title
    url
    feed
  end
end
