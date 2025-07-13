class VoltagesController < ApplicationController
    before_action :authenticate_user!
  
    def create
      @voltage = Voltage.new(voltage_params)
      @voltage.org_id = current_user.org_id
  
      if @voltage.save
        render turbo_stream: turbo_stream.update("voltage_section", partial: "uploads/voltage_dropdown", locals: {
          selected_voltage_id: @voltage.id,
          show_form: false,
          errors: []
        })
      else
        render turbo_stream: turbo_stream.update("voltage_section", partial: "uploads/voltage_dropdown", locals: {
          selected_voltage_id: nil,
          show_form: true,
          errors: @voltage.errors.full_messages
        })
      end
    end
  
    private
  
    def voltage_params
      params.require(:voltage).permit(:name)
    end
  end
  