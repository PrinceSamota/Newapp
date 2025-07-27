class WattagesController < ApplicationController
  
    def create
      @wattage = Wattage.new(wattage_params)
      @wattage.org_id = current_user.org_id
  
      if @wattage.save
        render turbo_stream: turbo_stream.update("wattage_section", partial: "uploads/wattage_dropdown", locals: {
          selected_wattage_id: @wattage.id,
          show_form: false,
          errors: []
        })
      else
        render turbo_stream: turbo_stream.update("wattage_section", partial: "uploads/wattage_dropdown", locals: {
          selected_wattage_id: nil,
          show_form: true,
          errors: @wattage.errors.full_messages
        })
      end
    end
  
    private
  
    def wattage_params
      params.require(:wattage).permit(:name)
    end
  end
  