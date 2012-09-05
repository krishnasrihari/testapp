require 'spec_helper'

describe "allocations/_find_companies" do
  subject { render }


  context "when soemthing is found" do
    before { assign :companies, [stub_model(Company, id: 123, name: 'RayWhite')] }

    it { should have_content 'RayWhite' }
    it { should have_selector "input[name='allocation[receiving_company_id]'][type=radio][value='123']" }
    it { should_not have_selector 'form' }
  end

  context 'when nothing found' do
    before { assign :companies, [] }
    it { should have_selector '.alert.alert-info' }
  end
end




