class DevelopmentsController < ApplicationController
  require_current_company!

  def index
    authorize! :index, Development
    @developments = current_user.available_developments_within(current_company)
  end

  def show
    @development = Development.find params[:id]
    authorize! :view, @development
  end

  def new
    authorize! :create, Development
    @development = Development.new
  end

  def create
    @development = Development.new params[:development]
    assign_company
    authorize! :create, Development
    if @development.save
      current_company.allow_users_to_access_development!(@development)
      Propagation.propagate_published_development current_company, @development
      redirect_to developments_url
    else
      render :new
    end
  end

  def edit
    @development = Development.find(params[:id])
    authorize! :edit, @development
  end

  def update
    @development = Development.find(params[:id])
    authorize! :edit, @development
    if @development.update_attributes params[:development]
      redirect_to developments_url
    else
      render :edit
    end
  end

  def destroy
    @development = Development.find(params[:id])
    authorize! :edit, @development
    @development.destroy
    redirect_to developments_url
  end


  private

  def assign_company
    @development.company = current_company
  end
end
