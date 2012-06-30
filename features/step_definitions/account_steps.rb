Given /^I have deposited (#{CASH_AMOUNT}) in my account$/ do |amount|  
  account.deposit(amount)
  account.balance.should eq(amount), "Expected the balance to be #{amount} but it was #{account.balance}"
end

Then /^I should see error message 'insuffient amount'$/ do
  pending
end