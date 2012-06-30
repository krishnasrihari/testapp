When /^I request (#{CASH_AMOUNT}) through atm$/ do |amount|	
	last_balance = account.balance	  
  teller.withdraw(account,amount)      
end
