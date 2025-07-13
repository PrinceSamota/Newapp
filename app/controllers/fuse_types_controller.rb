class FuseTypesController < ApplicationController
    before_action :authenticate_user!
  
    def create
      @fuse_type = FuseType.new(fuse_type_params)
      @fuse_type.org_id = current_user.org_id
  
      if @fuse_type.save
        render turbo_stream: turbo_stream.update("fuse_type_section", partial: "uploads/fuse_type_dropdown", locals: {
          selected_fuse_type_id: @fuse_type.id,
          show_form: false,
          errors: []
        })
      else
        render turbo_stream: turbo_stream.update("fuse_type_section", partial: "uploads/fuse_type_dropdown", locals: {
          selected_fuse_type_id: nil,
          show_form: true,
          errors: @fuse_type.errors.full_messages
        })
      end
    end
  
    private
  
    def fuse_type_params
      params.require(:fuse_type).permit(:name)
    end
  end
  