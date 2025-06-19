class OrganizationsController < ApplicationController
    def index
      @organizations = Organization.all
    end
  
    def new
      @organization = Organization.new
    end
  
    def create
      @organization = Organization.new(organization_params)
      if @organization.save
        redirect_to organizations_path, notice: 'Organization created successfully.'
      else
        render :new
      end
    end
  
    private
  
    def organization_params
      params.require(:organization).permit(:name)
    end
  end
  