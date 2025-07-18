class ExtrasController < ApplicationController
    before_action :authenticate_user!
  
    def create
      @extra = Extra.new(extra_params)
      @extra.org_id = current_user.org_id
  
      if @extra.save
        render turbo_stream: turbo_stream.update("extra_section", partial: "uploads/extra_dropdown", locals: {
          selected_extra_id: @extra.id,
          show_form: false,
          errors: []
        })
      else
        render turbo_stream: turbo_stream.update("extra_section", partial: "uploads/extra_dropdown", locals: {
          selected_extra_id: nil,
          show_form: true,
          errors: @extra.errors.full_messages
        })
      end
    end
  
    private
  
    def extra_params
      params.require(:extra).permit(:name)
    end
  end
  