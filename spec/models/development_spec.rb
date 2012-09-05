require 'spec_helper'

describe Development do

  it { should have_many :properties }
  it { should have_many(:allocation_items).dependent(:destroy) }
  it { should have_many(:documents).dependent(:destroy) }

  it { should have_one(:development_profile).dependent(:destroy) }

  it { should have_many(:gallery_images).dependent(:destroy) }

  [:address_line1, :address_city, :address_state, :address_postcode, :address_country].each do |attr|
    it  { should validate_presence_of(attr) }
  end

  its(:contract) { should be_nil }
  its(:brochure) { should be_nil }

  it "should have capital city" do
    subject.stub(address_country: 'Abc', address_state: 'Def')
    CapitalCities.should_receive(:for_country_and_state).with('Abc', 'Def').and_return 'my capital'
    subject.address_capital_city.should == 'my capital'
  end

  it "autosaves profile so that we don't have to bother saving it manually" do
    d = create :development, development_profile: DevelopmentProfile.new
    d.development_profile.capital_city_facts = 'abc'
    d.save!
    d.reload.development_profile.capital_city_facts.should == 'abc'
  end

  describe "#development_profile_or_default" do
    let(:d) { build :development }

    it "returns existing profile" do
      p = DevelopmentProfile.new
      d.development_profile = p
      d.development_profile_or_default.should == p
    end

    it "builds and returns a new profile when one isn't available" do
      d.development_profile = nil
      d.development_profile_or_default.should_not be_nil
      d.development_profile_or_default.should == d.development_profile
    end
  end

  context "for existing" do
    let(:dev) { create :development }
    subject { dev }
    its(:development_id) { should == dev.id }
  end

  it { should validate_presence_of      :name         }
  it { should validate_presence_of      :description  }
  it { should belong_to                 :company      }
  it { should validate_numericality_of  :company_id   }

  its(:status) { should == :inactive }
  its(:visibility) { should == :limited }
  its(:completion_date) { should be_nil }
  its(:construction_start_date) { should be_nil }

  its(:reservation_fee) { should == 1000 }
  its(:reservation_fee_period) { should == 48 } # hours

  it { should validate_numericality_of(:reservation_fee) }
  it { should validate_numericality_of(:reservation_fee_period) }

  it { should validate_presence_of :reservation_fee }
  it { should validate_presence_of :reservation_fee_period }

  it { should allow_value('1000').for(:reservation_fee) }
  it { should_not allow_value('-10').for(:reservation_fee) }
  it { should_not allow_value('0').for(:reservation_fee) }

  it { should allow_value('24').for(:reservation_fee_period) }
  it { should_not allow_value('-2').for(:reservation_fee_period) }
  it { should_not allow_value('0').for(:reservation_fee_period) }
  it { should_not allow_value('0.9').for(:reservation_fee_period) }

  it { should_not allow_value(0).for(:carpark_value) }
  it { should_not allow_value(-1).for(:carpark_value) }
  it { should allow_value(123).for(:carpark_value) }
  it { should allow_value(nil).for(:carpark_value) }
  it { should allow_value(' ').for(:carpark_value) }

  its(:capital_city_facts) { should be_nil }
  its(:capital_city_overview) { should be_nil }
  its(:suburb_facts) { should be_nil }
  its(:suburb_overview) { should be_nil }

  describe "Completion Date" do
    its(:completion_date) { should be_nil }

    context "none" do
      before { subject.completion_date = nil }
      its(:completion_date_as_quarter) { should == 'Unknown' }
    end

    {
      'Feb 2012'    => 'Q1 2012',
      'April 2012'  => 'Q2 2012',
      'July 2012'   => 'Q3 2012',
      'November 2012' => 'Q4 2012'
    }.each do |date, expected|
      context "#for #{date}" do
        before { subject.completion_date = Date.parse(date) }
        its(:completion_date_as_quarter) { should == expected }
      end
    end
  end

  describe "reservation options" do
    its(:allow_offline_reservations) { should be_false }
    its(:allow_offline_reservations?) { should be_false }

    its(:allow_live_reservations_with_payment) { should be_false }
    its(:allow_live_reservations_with_payment?) { should be_false }

    its(:allow_live_reservations) { should be_true }
    its(:allow_live_reservations?) { should be_true }
  end

  describe "#owned_by" do
    let(:company) { create :company }
    let(:owned)   { create :development, :company => company }
    let(:other)   { create :development }

    it "should only return owned developments" do
      all = Development.owned_by(company)
      all.should      include owned
      all.should_not  include other
    end
  end

  describe ".browsable" do
    subject { Development.scoped.browsable(current_company) }
    let(:developer)         { create :company }
    let!(:full)             { create :development, visibility: :full,             company: developer }
    let!(:limited)          { create :development, visibility: :limited,          company: developer }
    let!(:networks)         { create :development, visibility: :networks,         company: developer }
    let!(:networks_limited) { create :development, visibility: :networks_limited, company: developer }

    context "when current company doesn't own the development" do
      let(:current_company) { create :company }
      it { should include full }
      it { should include limited }
      it { should_not include networks }
      it { should_not include networks_limited }
    end

    context "when development is owned by the current company" do
      let(:current_company) { developer }
      it { should include full }
      it { should include limited }
      it { should include networks }
      it { should include networks_limited }
    end
  end

  describe "#filter_properties(filter)" do
    let(:development) { build :development }
    it "should apply the filter" do
      filter = stub('Filter')
      company, user = stub('Company'), stub('User')
      properties_set = stub('Base Props Set')
      development.properties.should_receive(:accessible_to).and_return properties_set
      PropertySearch.should_receive(:by_filter).with(filter, properties_set).and_return 'set of props'
      development.filter_properties(filter, user, company).should == 'set of props'
    end
  end


  describe "#address_one_line" do
    let(:dev) { build :development, address_line1: 'L1', address_line2: 'L2', address_city: 'MEL', address_state: 'VIC', address_postcode: '3000' }
    subject { dev.address_one_line }

    it { should == 'L1, L2, MEL, VIC 3000' }

    context "when there's no line2" do
      before { dev.address_line2 = ' ' }
      it { should == 'L1, MEL, VIC 3000' }
    end
    context "when there's no postcode" do
      before { dev.address_postcode = nil }
      it { should == 'L1, L2, MEL, VIC' }
    end
  end


  describe "image urls" do
    its(:image_thumb_url) { should be_nil }
    its(:image_medium_url) { should be_nil }
    its(:image_large_url) { should be_nil }

    let(:dev) { build :development, :image => path }

    context "with existing image" do
      let(:path) { 'spec/fixtures/development.jpg' }

      it "should resize to the thumbnail" do
        original, thumb = dev.image, stub('Thumb')
        original.should_receive(:thumb).with('100x100').and_return thumb
        thumb.should_receive(:url).and_return '/url'
        dev.image_thumb_url.should == '/url'
      end

      it "should resize to medium" do
        original, img = dev.image, stub('Image')
        original.should_receive(:thumb).with('300x300').and_return img
        img.should_receive(:url).and_return '/url'
        dev.image_medium_url.should == '/url'
      end
    end

    context "with no image" do
      let(:path) { nil }
      its(:image_thumb_url) { should be_nil }
      its(:image_medium_url) { should be_nil }
    end

  end


  describe ".by_term" do
    let(:details) { {name: 'Eureka'} }
    let!(:eureka) { create :development, details }
    subject { Development.scoped.by_term term }

    context "when partial match" do
      let(:term) { 're' }
      it { should include eureka }
    end
    context "when starts with" do
      let(:term) { 'eu' }
      it { should include eureka }
    end
    context "when ends with" do
      let(:term) { 'ka' }
      it { should include eureka }
    end
    context "when different" do
      let(:term) { 'rrr' }
      it { should_not include eureka }
    end

    context "by address suburb" do
      let(:details) { {address_city: 'South Melbourn'} }
      let(:term) { 'melb' }
      it { should include eureka }
    end
    context "by address street" do
      let(:details) { {address_line1: 'Clarendon'} }
      let(:term) { 'rendo' }
      it { should include eureka }
    end
    context "by address postcode" do
      let(:details) { {address_postcode: '3000'} }
      let(:term) { '000' }
      it { should include eureka }
    end
  end



  describe "deleting" do
    let(:developer) { create :company }
    let(:eureka) { create :development, company: developer }

    it "should delete all the selected participations for the development" do
      participation = create :participation, company: developer
      participation.developments = [eureka]
      participation.save!
      eureka.destroy
      participation.reload.developments.should be_empty
    end

    it "should delete the reservations on any of the properties" do
      p = create :property, development: eureka
      r = create :reservation, property: p
      eureka.destroy
      Reservation.find_by_id(r.id).should be_nil
    end

  end

end
