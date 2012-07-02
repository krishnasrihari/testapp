Given /^I have credited (#{CASH_AMOUNT}) in my account$/ do |amount|  
  account.credit(amount)
  account.balance.should eq(amount), "Expected the balance to be #{amount} but it was #{account.balance}"
end

Then /^the balance of amount should be (#{CASH_AMOUNT})$/ do |amount|
  account.balance.should eq(amount), "Incorrect balance amount"
end