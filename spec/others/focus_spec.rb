RSpec.configure do |c|
	c.filter = {:focus => true}
end

describe "Example Group" do
	it "Example 1", :focus => true do
	end
	
	it "Example 2", :focus => true do
	end
	
	it "Example 3" do
	end
end


describe "Example Group 2", :focus => true do
	it "example 1" do
	end
	it "example 2" do
	end
end

describe "Example group 3" do
	it "example 1" do
	end
	it "example 2" do
	end
end
