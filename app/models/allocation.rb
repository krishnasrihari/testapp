class Allocation < ActiveRecord::Base
  belongs_to :offering_company, class_name: 'Company'
  belongs_to :receiving_company, class_name: 'Company'
  belongs_to :offering_user, class_name: 'User'
  has_many :allocation_items, :dependent => :destroy

  has_many :developments, :through => :allocation_items
  has_many :property_groupings, :through => :allocation_items

  validates :offering_company, :receiving_company, :offering_user, :presence => true
  validates :receiving_company_id, :uniqueness => { scope: :offering_company_id }
  validate :offering_and_receiving_cannot_be_the_same

  attr_accessor :name
  attr_readonly :offering_company_id, :offering_user_id, :receiving_company_id

  delegate :name, :to => :receiving_company, prefix: true
  delegate :name, :to => :offering_company, prefix: true

  scope :with_future_access, where(:access_future_developments => true)
  scope :with_no_future_access, where(:access_future_developments => false)
  scope :offered_by, lambda{|offerer| where(:offering_company_id => offerer.try(:id)) }


  def total_developments
    developments.size
  end

  def update_from(params)
    self.attributes = params
    self.save!
    Propagation.propagate_allocation(self)
    Propagation.propagate_property_grouping(offering_company)
  end

  def setup_for(company, user)
    self.offering_company = company
    self.offering_user = user
  end


  def inspect
    "<Allocation: #{id}, #{offering_company_name} => #{receiving_company_name}>"
  end

  protected

  def offering_and_receiving_cannot_be_the_same
    errors.add(:receiving_company, 'cannot share with yourself') if self.offering_company == self.receiving_company
  end

end
