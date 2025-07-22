class StatusesController < ApplicationController
    def create
      @status = Status.new(status_params)
      @status.org_id = current_user.org_id
  
      if @status.save
        render json: { id: @status.id, name: @status.name }
      else
        render json: { errors: @status.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    private
  
    def status_params
      params.require(:status).permit(:name)
    end
  end
  