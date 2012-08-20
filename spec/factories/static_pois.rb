# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :static_poi do
    ref "MyString"
    ref_type "MyString"
    lat "MyString"
    lng "MyString"
  end
end
