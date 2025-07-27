class MeasurementsController < ApplicationController

    def new
      @measurement = Measurement.new
    end
  
    def create
        @measurement = Measurement.new(measurement_params)
        @measurement.org_id = current_user.org_id 
      
        if @measurement.save
          render turbo_stream: turbo_stream.update("measurement_section", partial: "uploads/measurement_dropdown", locals: {
            selected_measurement_id: @measurement.id,
            show_form: false,
            errors: []
          })
        else
          render turbo_stream: turbo_stream.update("measurement_section", partial: "uploads/measurement_dropdown", locals: {
            selected_measurement_id: nil,
            show_form: true,
            errors: @measurement.errors.full_messages
          })
        end
      end
    def index
      @measurements = Measurement.where(org_id: current_user.org_id)
    end
  
    private
  
    def measurement_params
      params.require(:measurement).permit(:name)
    end
  end
  