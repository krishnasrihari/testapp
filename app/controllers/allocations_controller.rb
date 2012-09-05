class AllocationsController < ApplicationController
  require_current_company!

  def new
    authorize! :allocate, current_company
    @allocation ||= Allocation.new
    @developments = current_company.developments_in_stock
    @property_groupings = current_company.property_groupings
    @companies ||= []
  end

  def find_companies
    authorize! :allocate, current_company
    @companies = CompanyFinder.by_name_or_user params[:allocation][:name]
    render partial: 'find_companies'
  end

  def create
    authorize! :allocate, current_company
    @allocation = Allocation.new params[:allocation]
    @allocation.setup_for current_company, current_user

    if @allocation.save
      redirect_to contacts_path
    else
      @companies = CompanyFinder.by_name_or_user params[:allocation][:name]
      new
      render :new
    end
  end


  def edit
    @allocation ||= Allocation.find params[:id]
    @companies = [@allocation.receiving_company]
    self.new
    render :edit
  end

  def update
    @allocation = Allocation.find params[:id]
    if @allocation.update_from params[:allocation]
      redirect_to contacts_url
    else
      edit
    end
  end
end
