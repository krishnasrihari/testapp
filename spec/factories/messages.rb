# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :message do |f|
    f.content "My text message"    
    f.association :user
  end
end
