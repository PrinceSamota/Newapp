class LoopsController < ApplicationController

    def create
      @loop = Loop.new(loop_params)
      @loop.org_id = current_user.org_id
  
      if @loop.save
        render turbo_stream: turbo_stream.update("loop_section", partial: "uploads/loop_dropdown", locals: {
          selected_loop_id: @loop.id,
          show_form: false,
          errors: []
        })
      else
        render turbo_stream: turbo_stream.update("loop_section", partial: "uploads/loop_dropdown", locals: {
          selected_loop_id: nil,
          show_form: true,
          errors: @loop.errors.full_messages
        })
      end
    end
  
    private
  
    def loop_params
      params.require(:loop).permit(:name)
    end
  end
  