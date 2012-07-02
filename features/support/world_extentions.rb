module MyAccount
	
	class UserInterface
		include Capybara::DSL
		
		def withdraw_from(account,amount)
			visit '/index'			
			fill_in 'account_amount', with: amount
			click_button 'withdraw'
		end
	end
	
	def account
		@account ||= Account.new
	end
	
	def cash_slot
		@cash_slot ||= CashSlot.new
	end
	
	def teller
		@teller ||= Teller.new(cash_slot)
	end	
end

World(MyAccount)

