require 'spec_helper'

describe "genres/index" do
  before(:each) do
    assign(:genres, [
      stub_model(Genre),
      stub_model(Genre)
    ])
  end

  it "renders a list of genres" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
