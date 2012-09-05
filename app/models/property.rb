class Property < ActiveRecord::Base
  has_paper_trail

  image_accessor :image
  has_resizable_image_on :image

  image_accessor :floorplan
  has_resizable_image_on :floorplan
  has_page_images_on :floorplan

  file_accessor :contract
  file_accessor :brochure

  attr_protected :status_locked, :name, :has_pending_reservation, :floorplan_name, :floorplan_uid, :floorplan_number_of_pages
  has_symbolic_field :status, [:inactive, :available, :held, :reserved, :under_contract, :sold]
  has_symbolic_field :nras_status, [:none, :active, :pending, :approved]

  belongs_to              :development
  has_and_belongs_to_many :documents
  has_and_belongs_to_many :gallery_images
  has_many                :reservations, :dependent => :destroy

  default_scope order: "properties.name"

  validates :number,
            :status,
            :price,
            :level,
            :bedrooms_number,
            :bathrooms_number,
            :carparks_number,
            :presence => true

  validates :level, :numericality => { :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100}
  validates :rent, :numericality => {greater_than: 0}, allow_nil: true

  validates :stamp_duty, :dutiable_amount, :numericality => {greater_than: 0}, allow_nil: true

  validates :bedrooms_number,
            :bathrooms_number,
            :carparks_number,
            :numericality => { :greater_than_or_equal_to => 0, :less_than_or_equal_to => 5}

  before_validation :set_full_name

  scope :by_status_filter, lambda { |filter| # One of :all, :unavailable, :available
    case filter
    when :all
      where {}
    when :unavailable
      where(status: ['held', 'reserved', 'inactive'])
    when :available
      where(status: ['available', 'inactive'])
    else
      raise "Unsupported filter #{filter}"
    end.where("properties.status <> 'deleted'")
  }

  scope :with_min_bedrooms, lambda{|beds| where('properties.bedrooms_number >= ?', beds) }
  scope :with_max_price, lambda{|mx| where('properties.price <= ?', mx) }

  def self.accessible_to(user, company)
    AccessibleProperties.for(user, company)
  end

  def self.stock_of(user, company)
    AccessibleProperties.stock_of(user, company)
  end

  scope :by_term, lambda {|term| where arel_table[:name].matches("%#{term}%") }

  def actual_gallery_images
    gallery_images.any? ? gallery_images : development.try(:gallery_images)
  end

  def actual_contract
    development.try(:contract) or contract
  end

  def actual_brochure
    development.try(:brochure) or brochure
  end

  def nras_rent
    rent? ? rent * 0.8 : nil
  end

  def estimated_rates
    rates? ? rates : price * 0.0025
  end

  def estimated_body_corp_rates
    body_corp_rates? ? body_corp_rates : price * 0.005
  end

  def actual_dutiable_amount
    return dutiable_amount if dutiable_amount?
    return price if development.completion_date? && development.completion_date.to_date < Date.today
    return price / 4 if !development.construction_start_date? || development.construction_start_date.to_date > Date.today
    if development.completion_date? and development.construction_start_date?
      constrcution_time = (development.completion_date - development.construction_start_date) / 1.hour
      hours_spent = (Date.today - development.construction_start_date.to_date) * 24
      progress = 1 - hours_spent / constrcution_time
      building_works_value = price * 0.75
      (price - building_works_value * progress).round
    else
      price / 4
    end
  end

  def actual_stamp_duty
    stamp_duty? ? stamp_duty : InvestmentReport::StampDuty.on_value(actual_dutiable_amount, development.try(:address_state))
  end

  def price_per_square_metre
    return 0 unless internal_area?
    price / internal_area
  end

  def advanced_price_per_square_metre
    return 0 unless development.carpark_value?
    ext = external_area || 0
    int = internal_area || 0
    ext = if ext <= 10
                 ext * 0.33
               elsif ext < 20
                 3.33 + (ext - 10)*0.25
               else
                 5.8 + (ext - 20)*0.15
               end
    usable = int + ext

    car_value = development.carpark_value * carparks_number
    no_car_price = price - car_value
    adv = no_car_price / usable
    adv.nan? || adv.infinite? ? 0 : adv
  end

  def reservable?
    status == :available
  end

  def status=(value)
    super unless status_locked?
  end

  def force_status(new_status)
    old = status_locked?
    self.status_locked = false
    self.status = new_status
  ensure
    self.status_locked = old
  end

  def set_full_name
    self.name = "#{development.try(:name)} - #{number}"
  end

  def collect_reservation_path(current_company)
    current_company.received_allocations

    groups_with_this_property = PropertyGrouping.select{id}.joins{properties}.where{properties.id == my{id}}

    allocation_items  = AllocationItem.joins{allocation}.
      where{allocation.receiving_company_id == current_company.id}.
      where{
        (development_id == my{development_id}) |
        (property_grouping_id.in groups_with_this_property)
      }.
      includes(:allocation => :receiving_company)
    ai = allocation_items.first
    raise "Property #{self.name} was received from multiple sources. Don't know what the reservation path would be." if allocation_items.size > 1
    path = ai.present? ? ai.path.map{|x| x.allocation.receiving_company } : []
    [development.company, *path]


    #allocation_devs = AllocationItem.joins(:allocation).
    #  where(development_id: self.development.id).
    #  where('allocations.receiving_company_id = ?', current_company.id).
    #  includes(:allocation => :receiving_company)
    #ad = allocation_devs.first
    #raise "Development #{development.name} was received from multiple sources. Don't know what the reservation path would be." if allocation_devs.size > 1
    #path = ad.present? ? ad.path.map {|ad| ad.allocation.receiving_company } : []
    #[development.company, *path]
  end

  def nras?
    nras_status != :none
  end

  def self.nras_incentive
    9981
  end

  def nras_incentive
    Property.nras_incentive
  end


  def to_s
    inspect
  end

  def inspect
    "<Property #{id}, #{name}>"
  end

end
