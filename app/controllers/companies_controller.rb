class CompaniesController < ApplicationController

  def new
    @company = Company.new
  end

  def create
    @company = Company.new params[:company]
    @company.primary_user = current_user
    if @company.save
      redirect_to dashboard_url, :notice => "The company has been created"
    else
      render :new
    end
  end
end
