class CoverTypesController < ApplicationController

    def create
      @cover_type = CoverType.new(cover_type_params)
      @cover_type.org_id = current_user.org_id
  
      if @cover_type.save
        render turbo_stream: turbo_stream.update("cover_type_section", partial: "uploads/cover_type_dropdown", locals: {
          selected_cover_type_id: @cover_type.id,
          show_form: false,
          errors: []
        })
      else
        render turbo_stream: turbo_stream.update("cover_type_section", partial: "uploads/cover_type_dropdown", locals: {
          selected_cover_type_id: nil,
          show_form: true,
          errors: @cover_type.errors.full_messages
        })
      end
    end
  
    private
  
    def cover_type_params
      params.require(:cover_type).permit(:name)
    end
  end
  