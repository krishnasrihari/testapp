require 'ping'

RSpec.configure do |c|
	c.exclusion_filter = {
		:if => lambda {|what|
			case what
			when :network_available
				!Ping.pingecho "example.com", 10, 80
			end
		}
	}
end

describe "Network group" do
	it "example 1", :if => :network_available do
	end
	it "example 2" do
	end
end
