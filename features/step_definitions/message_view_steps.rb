
Then /^I should see "(.*?)"$/ do |message|
  page.should have_content(message)
end
