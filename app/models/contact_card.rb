class ContactCard
  include ActiveAttr::Model
  attribute :type
  attribute :company_name
  attribute :contact_name
  attribute :contact_email
  attribute :role
  attribute :notes

  attribute :model

  def self.collect_for(company, user)
    ps = company.participations.map{|p| from_participation(p) }
    allocs = (company.received_allocations | company.offered_allocations).map{|a| from_allocation(a, company) }
    ps + allocs
  end

  def self.from_participation(p)
    ContactCard.new({
      model: p,
      type: :participation,
      company_name: p.company.name,
      contact_name: p.user.name,
      contact_email: p.user.email,
      role: p.category_name.singularize,
      notes: ''
    })
  end

  def self.from_allocation(a, current_company)
    company = a.offering_company == current_company ? a.receiving_company : a.offering_company
    ContactCard.new({
      model: a,
      type: a.offering_company == current_company ? :allocation_offered : :allocation_received,
      company_name: company.name,
      contact_name: company.primary_user.name,
      contact_email: company.primary_user.email,
      role: a.offering_company == current_company ?  'Sales Network' : 'Stock provider',
      notes: ''
    })
  end
end



