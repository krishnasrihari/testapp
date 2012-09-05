require 'spec_helper'

describe "developments/show" do
  let(:development) { stub_model Development, name: 'Eureka', address_one_line: 'Clarendon' }

  before { assign :development, development }
  before { view.stub(can?: true) }

  subject { render }

  it { should include 'Eureka' }
  it { should include 'Clarendon' }
end



