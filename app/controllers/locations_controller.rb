class LocationsController < ApplicationController
  def create
    @location = Location.new(location_params.merge(org_id: current_user.org_id))

    if @location.save
      @locations = Location.where(org_id: current_user.org_id)
      render partial: 'uploads/location_dropdown',
             locals: { selected_location_id: @location.id, show_form: false, errors: nil },
             formats: [:html]
    else
      @locations = Location.where(org_id: current_user.org_id)
      render partial: 'uploads/location_dropdown',
             locals: { selected_location_id: nil, show_form: true, errors: @location.errors.full_messages },
             formats: [:html]
    end
  end

  private

  def location_params
    params.require(:location).permit(:name)
  end
end
