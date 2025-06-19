class CategoriesController < ApplicationController
    before_action :authenticate_user!
  
    def new
      @category = Category.new
    end
  
    def create
        @category = Category.new(category_params)
        @category.org_id = current_user.org_id
      
        if @category.save
          render turbo_stream: turbo_stream.update("category_section", partial: "uploads/category_dropdown", locals: {
            selected_category_id: @category.id,
            show_form: false,
            errors: []
          })
        else
          render turbo_stream: turbo_stream.update("category_section", partial: "uploads/category_dropdown", locals: {
            selected_category_id: nil,
            show_form: true,
            errors: @category.errors.full_messages
          })
        end
      end
  
    def index
      @categories = Category.where(org_id: current_user.org_id)
    end
  
    private
  
    def category_params
      params.require(:category).permit(:name)
    end
  end
  