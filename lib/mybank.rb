class Account
	attr_accessor :amount
	
	def initialize
		@amount = 0
	end
	
	def deposit(amount)
		@amount = amount
	end
	
	def balance
		@amount
	end

	def withdraw(amount)
		@amount -= amount
	end	
end

class Teller
	def initialize(cash_slot)
		@cash_slot = cash_slot
	end
	
	def withdraw(account,amount)
		account.withdraw(amount)
		@cash_slot.depense(amount)
	end
end


class CashSlot
	def contents
		@contents or raise("I am empty")
	end
	
	def depense(amount)
		@contents = amount
	end
end