describe "check" do
	it "metadata" do
		pending
		p example.metadata		
	end
end

describe "metadata", :a => "A" do
	it "check b", :b => "B" do
		puts example.metadata[:a]
		puts example.metadata[:b]
	end
end
