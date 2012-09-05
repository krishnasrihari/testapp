require 'spec_helper'

describe Company do
  describe 'mandatory validations' do
    context "when company is new (such as during registration)" do
      it { should validate_presence_of :name }
      it { should allow_value(nil).for :address_line1 }
      it { should allow_value("").for :address_country }
    end

    context "when company already exists" do
      subject { create :company }
      [:name, :address_line1, :address_city, :address_state, :address_postcode, :address_country].each do |attr|
        it  { should validate_presence_of(attr) }
      end
    end
  end
  it { should validate_numericality_of  :primary_user_id }

  it { should have_many(:participations).dependent(:destroy) }
  it { should have_many(:users).through(:participations) }
  it { should have_many(:developments) }
  it { should have_many(:property_groupings) }

  it "should autosave primary user" do
    company = build(:company, :primary_user => nil)
    company.primary_user = build(:user)
    company.save!
    company.primary_user.should_not be_new_record
  end

  it "primary user becomes admin" do
    user = create :user
    company = create :company
    company.primary_user = user
    company.save!
    company.admins.should include user
  end

  it "should add primary user to list of users" do
    primary = build(:user)
    company = build :company, :primary_user => primary
    company.save!
    company.reload.users.should == [primary]
  end

  it "should have a list of admins" do
    c = create(:company)
    user = create(:user)
    c.invite_user!(user, :admin)
    # Admins is used in DefaultAccess and spec
    c.reload.admins.should include user
  end

  it "should swap primary user" do
    u1, u2 = create(:user), create(:user)
    company = create(:company, :primary_user => u1)
    company.primary_user = u2
    company.save!
    company.reload
    company.users.should include u1
    company.users.should include u2
    company.primary_user.should == u2
  end

  describe "#invite_user" do
    subject     { create :company }
    let(:user)  { create :user }

    context "when already invited" do
      let!(:existing) { subject.invite_user!(user, :sales) }
      it "should return existing" do
        subject.invite_user(user, :sales).should == existing
      end
      it "should update category" do
        subject.invite_user!(user, :managers).category.should == :managers
      end
    end

    it "should create new participation" do
      subject.invite_user(user, :admin).should_not be_persisted
    end

    it "should save with bang!" do
      subject.invite_user!(user, :admin).should be_persisted
    end
  end


  describe "#has_development?(dev)" do
    subject { company }
    let(:company)   { create :company }
    let(:developer) { create :company }
    let(:dev)       { create :development, company: developer }

    context "when allocated" do
      before { create :allocation, offering_company: developer, receiving_company: company, developments: [dev] }
      it { should have_development(dev) }
    end
    context "when owned" do
      let(:company) { developer }
      it { should have_development(dev) }
    end
    context "when not allocated" do
      it { should_not have_development(dev) }
    end
  end

  describe "#has_user?" do
    let(:company) { create :company }
    subject { company.has_user?(user) }

    context "when user participating" do
      let(:user) { company.users.first }
      it { should be_true }
    end
    context "when user is not participating" do
      let(:user) { create :user }
      it { should be_false }
    end
  end


  describe "#sales_network_of?" do
    it "is true when there's an allocation" do
      a = create(:allocation)
      offerer = a.offering_company
      receiver = a.receiving_company
      receiver.should be_sales_network_of(offerer)
    end

    it "is true for myself" do
      c = build(:company)
      c.should be_sales_network_of c
    end
  end

  describe "#agents_to_reserve_on_behalf_of" do
    subject { company.agents_to_reserve_on_behalf_of }
    let!(:company) { create :company }

    it { should include({'Staff' => [[company.primary_user.name, company.primary_user]]}) }

    context "for the companies that have allocations" do
      let!(:receiving_company) { allocation.receiving_company }
      let(:allocation) { create :allocation, offering_company: company }
      it { should include({'Sales Networks' => [[receiving_company.name, receiving_company.primary_user]]}) }
    end
  end

  describe "#reservations_for(user)" do
    context "within the same company" do
      subject { company.reservations_for(me) }
      let(:company) { create :company }

      let!(:me)             { company.invite_user!(create(:user), category).user }
      let!(:sales_user)     { company.invite_user!(create(:user), :sales).user }
      let!(:manager_user)   { company.invite_user!(create(:user), :managers).user }
      let!(:admin_user)     { company.invite_user!(create(:user), :admin).user }

      let!(:my_own_reservation)       { create :reservation, user: me,           company: company }
      let!(:sales_person_reservation) { create :reservation, user: sales_user,   company: company }
      let!(:manager_reservation)      { create :reservation, user: manager_user, company: company }
      let!(:admin_reservation)        { create :reservation, user: admin_user,   company: company }

      before do
        my_own_reservation.update_attribute(:path, [company])
        sales_person_reservation.update_attribute(:path, [company])
        manager_reservation.update_attribute(:path, [company])
        admin_reservation.update_attribute(:path, [company])
      end

      context "when admin" do
        let(:category) { :admin }
        it { should include my_own_reservation }
        it { should include sales_person_reservation }
        it { should include manager_reservation }
        it { should include admin_reservation }
      end
      context "when manager" do
        let(:category) { :managers }
        it { should include my_own_reservation }
        it { should include sales_person_reservation }
        it { should include manager_reservation }
        it { should include admin_reservation }
      end
      context "when sales person" do
        let(:category) { :sales }
        it { should include my_own_reservation }
        it { should_not include sales_person_reservation }
        it { should_not include manager_reservation }
        it { should_not include admin_reservation }
      end
      context "when I'm within other company" do
        subject { create(:company).reservations_for(me) }
        let(:category) { :admin }
        it { should_not include sales_person_reservation }
        it { should_not include manager_reservation }
        it { should_not include admin_reservation }
      end
    end

    context "within an offering company" do
      it "includes the reservation from the agent that received an allocation from offering company" do
        offering_company = create :company
        offering_user = offering_company.primary_user
        receiving_company = create :company
        receiving_user = receiving_company.primary_user
        reservation = create :reservation, company: receiving_company, user: receiving_user
        reservation.update_attribute :path, [offering_company, receiving_company]
        offering_company.reservations_for(offering_user).should include reservation
      end
      it "doesn't include the reservation from the agent that received an allocation not from us"
    end
  end


  describe "#developments_in_stock" do
    let(:company) { create :company }
    subject { company.developments_in_stock }

    context "with owned development" do
      let!(:owned) { create :development, company: company }
      it { should include owned }
    end
    context "with allocated development" do
      let!(:allocated) { create :development }
      let!(:allocation) { create(:allocation, receiving_company: company, developments: [allocated]) }
      it { should include allocated }

      it "should have offered allocations" do
        allocation.offering_company.offered_allocations.should include allocation
      end
    end
    context "with allocated group" do
      let!(:allocated)  { create :development, name: 'Group given' }
      let(:developer)   { allocated.company }
      let!(:p1)         { create(:property, development: allocated) }
      let(:group)       { create(:property_grouping, company: developer, development: allocated, properties: [p1]) }
      let!(:allocation) { create(:allocation, offering_company: developer, receiving_company: company, property_groupings: [group]) }
      it { should include allocated }

      context "and other development that is not given" do
        let!(:not_given) { create :development, name: 'Not Given', company: allocation.offering_company }
        xit { should_not include not_given }
      end
    end
  end

  describe "#properties_in_stock" do
    it "delegates out" do
      AccessibleProperties.should_receive(:stock_of_company).with(subject).and_return 'xxx'
      subject.properties_in_stock.should == 'xxx'
    end
  end

  describe "#allow_users_to_access_development!(development)" do
    let(:dev)     { create :development }
    let(:company) { dev.company }
    let(:participation) { company.participations.first }

    it "should give access to all" do
      company.allow_users_to_access_development!(dev)
      participation.developments.should include dev
    end

    it "should not give access if it was previously removed" do
      company.allow_users_to_access_development!(dev)
      participation.developments = []; participation.save!
      company.allow_users_to_access_development!(dev)
      participation.developments.should_not include dev
      participation.should have(1).development_participation
    end
  end
end
