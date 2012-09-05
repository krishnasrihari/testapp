require 'spec_helper'

describe "messages/show" do
  before(:each) do
    @message = assign(:message, stub_model(Message))
  end

  it "renders attributes in <p>" do
  	assign(:message, double(:message, :text => "Hello world"))
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
