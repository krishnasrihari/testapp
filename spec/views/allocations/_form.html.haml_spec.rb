require 'spec_helper'

describe "allocations/_form" do
  subject { render partial: "allocations/form"  }
  let(:allocation) { stub_model(Allocation) }
  before { assign :allocation, allocation }
  before { assign :companies, [stub_model(Company, name: 'RayWhite')] }

  context "when creating a new one" do
    before { allocation.stub(persisted?: false) }
    it { should have_selector "form input[name='allocation[name]']" }
    it { should have_selector "form input[type=submit]" }

    describe "dynamic behaviour for the Find button" do
      it { should have_selector "[data-sendreplace-url='#{find_companies_allocations_path}']" }
      it { should have_selector "[data-sendreplace-params='#allocation_name']" }
      it { should have_selector "[data-sendreplace-replace='#company-selection']" }
    end
  end

  context "when editing existing" do
    before { allocation.stub(persisted?: true) }
    it { should_not have_selector "form input[name='allocation[name]']" }
  end

  it { should have_selector "form input[name='allocation[development_ids][]']" }
  it { should have_selector "form input[name='allocation[property_grouping_ids][]']" }
  it { should have_selector "form input[name='allocation[access_future_developments]']" }

  it { should have_selector "#company-selection" }

  it "should render the default (basically none) receiving_company field" do
    should have_selector "#company-selection .radio_buttons label"
    should have_content 'RayWhite'
  end

end



