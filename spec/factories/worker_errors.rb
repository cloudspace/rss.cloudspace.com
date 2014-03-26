# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :worker_error do
    element_type "MyString"
    element_id 1
    element_state "MyText"
    backtrace "MyText"
  end
end
