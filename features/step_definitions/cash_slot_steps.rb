Then /^(#{CASH_AMOUNT}) should be dispensed$/ do |amount|
  cash_slot.contents.should == amount
end

Then /^(#{CASH_AMOUNT}) should not be dispensed$/ do |amount|
  cash_slot.contents.should == 0
end

