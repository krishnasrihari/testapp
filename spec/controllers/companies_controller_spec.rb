require 'spec_helper'

describe CompaniesController do

  describe "#new" do
    subject { get(:new); self }
    its(:assigns, :company) { should_not be_nil }
  end


  describe "#create" do
    subject { post(:create, :company => attributes_for(:company)); self }
    its(:assigns, :company) { should_not be_nil }

    context "on success" do
      before { Company.any_instance.stub(:save => true) }
      its(:response) { should be_redirect }
    end
    context "on error" do
      before { Company.any_instance.stub(:save => false) }
      its(:response) { should render_template :new }
    end
  end


end
