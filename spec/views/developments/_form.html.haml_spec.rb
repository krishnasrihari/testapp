require 'spec_helper'

describe "developments/_form" do
  subject { render partial: "developments/form"  }

  let(:development) { stub_model Development, :persisted? => false,
    contract: 'xx',
    brochure: 'xx'
  }

  before  { assign :development, development }

  it { should have_selector "input[name='development[carpark_value]']"}

  %w{full limited networks networks_limited}.each do |value|
    it "should have visibility option for '#{value}'" do
      subject.should have_selector "input[type=radio][name='development[visibility]'][value=#{value}]"
    end
  end


  %w{inactive active}.each do |value|
    it "should have status option for '#{value}'" do
      subject.should have_selector "input[type=radio][name='development[status]'][value=#{value}]"
    end
  end

  it { should have_selector "select[name='development[completion_date(1i)]']" }
  it { should have_selector "select[name='development[completion_date(2i)]']" }
  it { should_not have_selector "select[name='development[completion_date(3i)]']" } # no day

  it { should have_selector "select[name='development[construction_start_date(1i)]']" }
  it { should have_selector "select[name='development[construction_start_date(2i)]']" }
  it { should_not have_selector "select[name='development[construction_start_date(3i)]']" } # no day

  # allows to clear the date
  it { should have_selector "select[name='development[completion_date(1i)]'] option[value='']" }
  it { should have_selector "select[name='development[completion_date(2i)]'] option[value='']" }


  it { should have_selector "input[type=checkbox][name='development[allow_live_reservations]']"}
  it { should have_selector "input[type=checkbox][name='development[allow_live_reservations_with_payment]']"}
  it { should have_selector "input[type=checkbox][name='development[allow_offline_reservations]']"}

  it { should have_selector "input[name='development[reservation_fee]']"}
  it { should have_selector "input[name='development[reservation_fee_period]']"}

  it { should have_selector "input[name='development[image]']"}

  it { should have_selector "input[name='development[contract]']"}
  it { should have_selector "input[name='development[remove_contract]']"}

  it { should have_selector "input[name='development[brochure]']"}
  it { should have_selector "input[name='development[remove_brochure]']"}
end

