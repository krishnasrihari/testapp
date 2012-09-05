require 'spec_helper'

describe Allocation do
  it { should belong_to :offering_company }
  it { should belong_to :receiving_company }
  it { should belong_to :offering_user }

  its(:developments) { should be_empty }
  its(:allocation_items) { should be_empty }

  it { should validate_presence_of :offering_company }
  it { should validate_presence_of :receiving_company }
  it { should validate_presence_of :offering_user }

  its(:access_future_developments) { should == true }

  describe "user mental model" do
    its(:name) { should be_blank }
  end

  it "should not be able to change offering, receiving details" do
    a = create(:allocation)
    c1, c2 = create(:company), create(:company)
    u1 = c1.primary_user
    a.update_attributes!(offering_company_id: c1.id, offering_user_id: u1.id, receiving_company_id: c2.id)
    a.reload
    a.offering_company_id.should_not == c1.id
    a.offering_user.should_not == u1.id
    a.receiving_company_id.should_not == c2.id
  end

  it "should not be able to allocate to ourselves" do
    we = create(:company)
    a = build(:allocation, offering_company: we, receiving_company: we)
    a.should_not be_valid
    a.should have(1).error_on(:receiving_company)
  end


  describe "#setup_for(company, user)" do
    let(:company) { build :company }
    let(:user)    { build :user }
    before { subject.setup_for(company, user) }

    its(:offering_company) { should == company }
    its(:offering_user) { should == user }
  end

  describe "#receiving_company_name" do
    before { subject.receiving_company = Company.new(name: 'RayWhite') }
    its(:receiving_company_name) { should == 'RayWhite' }
  end
  describe "#offering_company_name" do
    before { subject.offering_company = Company.new(name: 'RayWhite') }
    its(:offering_company_name) { should == 'RayWhite' }
  end
  describe "#total_developments" do
    before { subject.developments << Development.new << Development.new }
    its(:total_developments) { should == 2 }
  end

  describe "single allocation between 2 companies" do
    let!(:a) { create :allocation }
    it { should validate_uniqueness_of(:receiving_company_id).scoped_to(:offering_company_id).with_message /exist/i }
  end

  describe "scope of future access" do
    let!(:future) { create :allocation, access_future_developments: true }
    let!(:past) { create :allocation, access_future_developments: false }

    describe ".with_future_access" do
      subject { Allocation.scoped.with_future_access }
      it { should include future }
      it { should_not include past }
    end
    describe ".with_no_future_access" do
      subject { Allocation.scoped.with_no_future_access }
      it { should_not include future }
      it { should include past }
    end
  end

  describe "#update_from(params, company)" do
    let(:params) { {} }
    let(:allocation) { create :allocation }
    before { Propagation.stub(:propagate_allocation) }

    it "should update attributes" do
      allocation.should_receive(:attributes=).with(params)
      allocation.should_receive(:save!)
      allocation.update_from(params)
    end

    it "should propagate the developments" do
      Propagation.should_receive(:propagate_allocation).with(allocation)
      allocation.update_from(params)
    end

    it "should propagate the property groupings" do
      Propagation.should_receive(:propagate_property_grouping).with(allocation.offering_company)
      allocation.update_from(params)
    end
  end

  it "should be auditable"
  
  describe "propagation" do
    it "should delete all nested when deleting the parent"
    it "should remove a single development when it is removed"
    it "should add newly checked development to the nested with access to future developments"
  end
end
