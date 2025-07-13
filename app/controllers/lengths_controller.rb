class LengthsController < ApplicationController
    before_action :authenticate_user!
  
    def create
      @length = Length.new(length_params)
      @length.org_id = current_user.org_id
  
      if @length.save
        render turbo_stream: turbo_stream.update("length_section", partial: "uploads/length_dropdown", locals: {
          selected_length_id: @length.id,
          show_form: false,
          errors: []
        })
      else
        render turbo_stream: turbo_stream.update("length_section", partial: "uploads/length_dropdown", locals: {
          selected_length_id: nil,
          show_form: true,
          errors: @length.errors.full_messages
        })
      end
    end
  
    private
  
    def length_params
      params.require(:length).permit(:name)
    end
  end
  