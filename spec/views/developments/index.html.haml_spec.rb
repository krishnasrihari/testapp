require 'spec_helper'

describe "developments/index" do
  subject { render }

  let(:company) { stub name: 'RayWhite' }

  before { view.stub(current_company: company) }
  before { assign :developments, [] }

  it { should have_content 'RayWhite' }
  it { should render_template(partial: 'developments/_developments') }

end




