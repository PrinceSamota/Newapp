class LocationsController < ApplicationController
    before_action :authenticate_user!
  
    def create
      @location = Location.new(location_params)
      @location.org_id = current_user.org_id
  
      if @location.save
        render turbo_stream: turbo_stream.update("location_section", partial: "dispatches/location_section", locals: {
          selected_location_id: @location.id,
          show_form: false,
          errors: []
        })
      else
        render turbo_stream: turbo_stream.update("location_section", partial: "dispatches/location_section", locals: {
          selected_location_id: nil,
          show_form: true,
          errors: @location.errors.full_messages
        })
      end
    end
  
    private
  
    def location_params
      params.require(:location).permit(:name)
    end
  end
  