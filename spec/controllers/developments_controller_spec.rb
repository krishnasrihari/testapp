require 'spec_helper'

describe DevelopmentsController do
  let(:company) { create :company }
  let(:me)      { company.users.first }

  let(:development) { create :development, :company => company }
  let(:attrs)       { attributes_for(:development) }

  before        { sign_in me }
  before        { switch_company company }

  ignore_authorization!

  describe "#index" do
    subject { get(:index); self }

    it "assigns developments" do
      devs = [1,2,3]
      current_user.should_receive(:available_developments_within).with(company).and_return devs
      subject
      assigns(:developments).should == devs
    end

    it "requires current company" do
      switch_company nil
      subject.should redirect_to edit_current_company_path
    end
  end

  describe "#new" do
    subject { get(:new); self }
    its(:assigns, :development) { should_not be_nil }
  end

  describe "#create" do
    subject { post(:create, development: attrs); self }
    its(:assigns, :development) { should_not be_nil }
    its(:response) { should be_redirect }

    it "should execute automatic propagation" do
      Propagation.should_receive(:propagate_published_development).with company, an_instance_of(Development)
      subject
    end

    it "gives access to all users of the company" do
      company.should_receive(:allow_users_to_access_development!).with an_instance_of(Development)
      subject
    end

    context "on error" do
      let(:attrs) { attributes_for(:development, name: '') }
      its(:response) { should render_template :new }
    end
  end

  describe "#edit" do
    subject { get(:edit, development: attrs, id: development.id); self }
    its(:assigns, :development) { should_not be_nil }
  end

  describe "#update" do
    subject { post(:update, development: attrs, id: development.id); self }
    its(:assigns, :development) { should_not be_nil }
    context "on success" do
      before { Development.any_instance.stub(:update_attributes => true) }
      its(:response) { should be_redirect }
    end
    context "on error" do
      before { Development.any_instance.stub(:update_attributes => false) }
      its(:response) { should render_template :edit }
    end
  end

  describe "#destroy" do
    it "deletes the development" do
      Development.any_instance.should_receive(:destroy)
      post(:destroy, id: development.id)
    end
  end

  describe "#show" do
    let(:property)    {  stub }
    subject { get(:show, id: development.id); self }

    it "should authorise" do
      should_authorize_for(:view, development)
      subject
    end

    its(:assigns) { should have_key(:development) }
  end

  describe "Image" do
    render_views
    it "should have Image upload field" do
      dev = development
      get(:edit, :id => dev.id).should have_selector "form input[type='file'][name='development[image]']"
    end
  end
end
