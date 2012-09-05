class Development < ActiveRecord::Base
  image_accessor :image
  has_resizable_image_on :image

  file_accessor :contract
  file_accessor :brochure

  has_symbolic_field :status, [:inactive, :active]
  has_symbolic_field :visibility, {
    full:             'Full access',
    limited:          'Limited access',
    networks:         'Networks (Full access)',
    networks_limited: 'Networks (Limited access)'
  }

  belongs_to :company
  has_many   :properties, :dependent => :destroy, :uniq => true
  has_many   :documents,  :dependent => :destroy
  has_many   :gallery_images,   :dependent => :destroy, :order => 'gallery_images.position'
  has_many   :allocation_items, :dependent => :destroy
  has_many   :development_participations, :dependent => :destroy
  #has_and_belongs_to_many :participations
  has_one   :development_profile, :dependent => :destroy, autosave: true

  %w{capital_city_facts capital_city_overview suburb_facts suburb_overview}.each do |profile_method|
    delegate profile_method, to: :development_profile, allow_nil: true
  end


  validates :name, :description, :presence => true
  validates :carpark_value, :numericality => { :greater_than => 0 }, allow_nil: true
  validates :reservation_fee, :reservation_fee_period, :presence => true
  validates :reservation_fee, numericality: {greater_than_or_equal_to: 50}
  validates :reservation_fee_period, numericality: {greater_than_or_equal_to: 1, less_than_or_equal_to: 30*24 }
  has_address

  validates :company,          :presence => true
  validates :company_id,       :numericality => true, :allow_nil => true

  def development_id
    self.id
  end

  scope :owned_by, lambda {|owning_company| where :company_id => owning_company.try(:id) }
  scope :browsable, lambda {|current_company|
    visible = arel_table[:visibility].in([:full, :limited])
    owned_by_company = arel_table[:company_id].eq(current_company.try(:id))
    where(visible.or(owned_by_company))
  }

  scope :by_term, lambda {|term|
    conditions = [:name, :address_line1, :address_city, :address_postcode].map do |field|
      arel_table[field].matches "%#{term}%"
    end
    where conditions.inject{|ors, current| ors.or(current) }
  }


  def development_profile_or_default
    return development_profile if development_profile.present?
    build_development_profile
  end


  def filter_properties(filter, current_user, current_company)
    source = properties.accessible_to(current_user, current_company)
    PropertySearch.by_filter(filter, source)
  end

  def completion_date_as_quarter
    return "Unknown" unless self.completion_date
    quarter = case self.completion_date.month # Jan is 1st
      when 1..3 then 1
      when 4..6 then 2
      when 7..9 then 3
      else 4
    end
    "Q#{quarter} #{completion_date.year}"
  end


  def inspect
    "#<Development #{id}, #{name}>, #{status}>"
  end
end
