class Company < ActiveRecord::Base

  has_many :participations, :dependent => :destroy, :autosave => true
  has_many :users, :through => :participations, :autosave => true, :dependent => :destroy
  has_many :property_groupings, :dependent => :destroy


  has_many :developments, :autosave => true, :dependent => :destroy
  has_many :reservations
  has_many :received_allocations, class_name: 'Allocation', foreign_key: 'receiving_company_id'
  has_many :offered_allocations, class_name: 'Allocation', foreign_key: 'offering_company_id'
  has_many :received_developments, :through => :received_allocations, source: :developments
  has_many :received_property_groupings, :through => :received_allocations, source: :property_groupings
  belongs_to :primary_user, :class_name => 'User', :autosave => true

  accepts_nested_attributes_for :primary_user

  has_address validate_on: :update

  validates :name,            :presence => true
  validates :primary_user,    :presence => true
  validates :primary_user_id, :numericality => true, :allow_nil => true

  before_validation :ensure_primary_user_is_admin

  def reservations_for(user)
    #TODO: Replace SQL LIKE '%%' with something that can be indexed
    # See: http://stackoverflow.com/questions/10168486/effectively-query-on-column-that-includes-a-substring
    result = Reservation.where("reservations.reservation_path LIKE '%/?/%'", self.id)
    result = result.where(user_id: user.id) unless [:admin, :managers].include? user.category_within(self)
    result
  end

  def admins
    users.where('participations.category = ?', :admin)
  end

  def invite_user(user, category, options={})
    p = participations.where(user_id: user.id, company_id: self.id).first
    (p ||= Participation.new).tap do |me|
      me.company = self
      me.user = user
      me.category = category
      allowed = options[:developments]
      me.developments = allowed if allowed
    end
  end

  def invite_user!(*args)
    invite_user(*args).tap do |p|
      p.save!
    end
  end

  def has_development?(dev)
    developments_in_stock.include? dev
  end

  def has_user?(user)
    users.include?(user)
  end

  def sales_network_of?(other_company)
    self == other_company or received_allocations.offered_by(other_company).any?
  end

  def agents_to_reserve_on_behalf_of
    #TODO: SQLify the map.map!
    network_users = self.offered_allocations.map(&:receiving_company).map { |c| [c.name, c.primary_user] }
    {
      'Staff' => self.users.map { |u| [u.name, u] },
      'Sales Networks' => network_users
    }
  end


  def developments_in_stock 
    developments | received_developments | Development.where(id: received_property_groupings.select('property_groupings.development_id'))
  end

  def properties_in_stock
    AccessibleProperties.stock_of_company(self)
  end

  def allow_users_to_access_development!(development)
    transaction do
      participations.each do |p|
        denied = p.development_participations.where(development_id: development.id, allowed: false).any?
        p.add_development!(development) unless denied
      end
    end
  end

  protected

  def ensure_primary_user_is_admin
    participations.build(:user => primary_user, :category => :admin) unless users.include?(primary_user)
  end
end
