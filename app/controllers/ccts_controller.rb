class CctsController < ApplicationController
    before_action :authenticate_user!
  
    def create
      @cct = Cct.new(cct_params)
      @cct.org_id = current_user.org_id
  
      if @cct.save
        render partial: "uploads/cct_dropdown", locals: {
          selected_cct_id: @cct.id,
          show_form: false,
          errors: []
        }
      else
        render partial: "uploads/cct_dropdown", locals: {
          selected_cct_id: nil,
          show_form: true,
          errors: @cct.errors.full_messages
        }
      end
    end
  
    private
  
    def cct_params
      params.require(:cct).permit(:name)
    end
  end
  