class Account < ActiveRecord::Base
  attr_accessible :amount
  
  def initialize
		@amount = 0
	end
	
	def credit(amount)
		@amount = amount
	end
	
	def balance
		@amount
	end

	def debit(amount)
		if @amount > amount
			@amount -= amount
			true
		else
			false 
		end
	end	
end


class Teller
	def initialize(cash_slot)
		@cash_slot = cash_slot
	end
	
	def withdraw(account,amount)
		if account.debit(amount)
			@cash_slot.depense(amount)
		end
	end
	
	def withdraw_form(account,amount)
		MyAccount::UserInterface.new.withdraw_from(account,amount)
	end
end


class CashSlot
	def contents
		@contents or 0
	end
	
	def depense(amount)
		@contents = amount
	end
end