class SuppliersController < ApplicationController
  def create
    @supplier = Supplier.new(supplier_params)
    @supplier.org_id = current_user.org_id
  
    if @supplier.save
      @selected_supplier_id = @supplier.id
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "supplier_section",
            partial: "uploads/supplier_dropdown",
            locals: { selected_supplier_id: @selected_supplier_id, show_form: false  }
          )
        end
      end
    else
      flash[:supplier_errors] = @supplier.errors.full_messages
      redirect_back fallback_location: root_path
    end
  end
  
  
    private
  
    def supplier_params
      params.require(:supplier).permit(:name)
    end
  end
  