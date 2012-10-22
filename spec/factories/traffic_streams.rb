# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :traffic_stream do
    source "MyString"
    received_at "2012-10-19 15:49:08"
  end
end
