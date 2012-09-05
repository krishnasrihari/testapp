require 'spec_helper'

describe AllocationsController do
  let(:company) { create :company }
  let(:user)    { company.primary_user }

  before { switch_company company }
  before { sign_in user }

  ignore_authorization!

  describe "#new" do
    it "assigns necessary variables" do
      company.should_receive(:developments_in_stock).and_return 'Devs'
      company.should_receive(:property_groupings).and_return 'Gs'
      get(:new)
      assigns(:allocation).should be_an_instance_of(Allocation)
      assigns(:developments).should == 'Devs'
      assigns(:property_groupings).should == 'Gs'
      assigns(:companies).should == []
    end

    it "should authorise" do
      should_authorize_for(:allocate, company)
      get(:new)
    end
  end

  describe "#find_companies" do
    let(:data) { {'name' => 'abc'} }
    it "should assign the search result" do
      CompanyFinder.should_receive(:by_name_or_user).with('abc').and_return 'Found companies'
      get(:find_companies, :allocation => data)
      assigns(:companies).should == 'Found companies'
    end

    it "should authorise" do
      should_authorize_for(:allocate, company)
      get(:find_companies, :allocation => data)
    end
  end

  describe "#create" do
    let(:allocation) { stub 'Allocation', save: success, setup_for: 'xx' }
    let(:data) { {'name' => 'abc'} }
    before { Allocation.should_receive(:new).with(data).and_return allocation }

    context "on success" do
      let(:success) { true }
      it "redirects" do
        post(:create, allocation: data).should redirect_to contacts_url
      end

      it "should authorise" do
        should_authorize_for(:allocate, company)
        post(:create, allocation: data)
      end
    end

    context "on error" do
      let(:success) { false }

      it "assigns necessary variables" do
        company.should_receive(:developments_in_stock).and_return 'Devs'
        post(:create, allocation: data)
        assigns(:allocation).should == allocation
        assigns(:developments).should == 'Devs'
      end

      it "sets the defaults on the new allocation" do
        allocation.should_receive(:setup_for).with(company, current_user)
        post(:create, allocation: data)
      end

      it "preserves the selected companies" do
        CompanyFinder.should_receive(:by_name_or_user).with('abc').and_return 'Filtered companies'
        post(:create, allocation: data)
        assigns(:companies).should == 'Filtered companies'
      end
    end
  end


  describe "#edit" do
    subject { get(:edit, id: '123') }
    let(:allocation) { stub 'Allocation' }
    before { Allocation.should_receive(:find).with('123').and_return allocation }
    before { allocation.should_receive(:receiving_company).and_return 'Receiving company' }
    before { company.should_receive(:developments_in_stock).and_return 'Devs' }

    it "should authorise"

    it { should render_template :edit }
    it "sets variables" do
      subject
      assigns(:allocation).should == allocation
      assigns(:developments).should == 'Devs'
      assigns(:companies).should == ['Receiving company']
    end
  end


  describe "#update" do
    let(:allocation) { stub 'Allocation' }
    let(:data) { {'name' => 'abc'} }
    before { Allocation.should_receive(:find).with('123').and_return allocation }
    before { allocation.should_receive(:update_from).with(data).and_return success }
    subject { post :update, id: '123', allocation: data }

    it "should authorise"

    context "on success" do
      let(:success) { true }
      it { should redirect_to contacts_url }
    end

    context "on error" do
      let(:success) { false }
      before { allocation.should_receive(:receiving_company).and_return 'Receiving company' }
      before { company.should_receive(:developments_in_stock).and_return 'Devs' }
      it "sets variables" do
        subject
        assigns(:allocation).should == allocation
        assigns(:developments).should == 'Devs'
        assigns(:companies).should == ['Receiving company']
      end
      it { should render_template :edit }
    end

  end
end
