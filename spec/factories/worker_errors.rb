# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :worker_error do
    element_type 'Feed'
    element_id 1
    element_state '<#Feed blah blah blah>'
    Message 'Something went wrong!'
    backtrace 'stack trace'
  end
end
