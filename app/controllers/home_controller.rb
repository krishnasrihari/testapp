class HomeController < ApplicationController	
	
	def index				
	end
	
	def withdraw
		account = Account.new
		teller = Teller.new(cash_slot = CashSlot.new)		
		teller.withdraw(account,params[:account_amount])
		redirected_to :action => :index
	end	
	
end
