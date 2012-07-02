class SearchesController < ApplicationController
	def show
		@messages = Message.like(params[:searches] ? params[:searches][:query] : nil)
	end
end