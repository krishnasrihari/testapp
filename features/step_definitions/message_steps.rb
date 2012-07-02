Given /^there is a User$/ do
  FactoryGirl.create(:user)
end

Given /^the User has posted the message "(.*?)"$/ do |msg_text|
  User.count.should == 1
  FactoryGirl.create(:message, :content=>msg_text, :user=> User.first)
end

When /^I visit the page for the User$/ do
  User.count.should == 1
  visit(user_path(User.first))
end
