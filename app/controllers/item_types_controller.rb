class ItemTypesController < ApplicationController
    before_action :authenticate_user!
  
    def create
      @item_type = ItemType.new(item_type_params)
      @item_type.org_id = current_user.org_id
  
      if @item_type.save
        render turbo_stream: turbo_stream.update("item_type_section", partial: "uploads/item_type_dropdown", locals: {
          selected_item_type_id: @item_type.id,
          show_form: false,
          errors: []
        })
      else
        render turbo_stream: turbo_stream.update("item_type_section", partial: "uploads/item_type_dropdown", locals: {
          selected_item_type_id: nil,
          show_form: true,
          errors: @item_type.errors.full_messages
        })
      end
    end
  
    private
  
    def item_type_params
      params.require(:item_type).permit(:name)
    end
  end
  