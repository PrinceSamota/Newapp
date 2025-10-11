class DescriptionOfGoodsController < ApplicationController
    def create
        @description = DescriptionOfGood.new(description_params)
        @description.org_id = current_user.org_id
      
        if @description.save
          @descriptions = DescriptionOfGood.where(org_id: current_user.org_id)
          render turbo_stream: turbo_stream.replace(
            "description_section",
            partial: "inputs/description_dropdown",
            locals: { selected_description_id: @description.id }
          )
          
        else
          render turbo_stream: turbo_stream.replace(
            "description_section",
            partial: "inputs/description_dropdown",
            locals: { selected_description_id: nil, show_form: true, errors: @description.errors.full_messages }
          )
        end
      end
      
  
    private
  
    def description_params
      params.require(:description_of_good).permit(:name)
    end
  end
  