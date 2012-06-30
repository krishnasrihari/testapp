When /^I request (#{CASH_AMOUNT}) through atm$/ do |amount|		  
  teller.withdraw(account,amount)  
end
