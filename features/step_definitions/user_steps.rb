Given /^a User has posted the following messages:$/ do |messages|
	user = FactoryGirl.create(:user)
	puts "map: #{messages.hashes.map}"	
	messages.hashes.each do |msg_attr|
		user.messages.create!(msg_attr)
		puts "attr: #{msg_attr}"			
	end		
end
