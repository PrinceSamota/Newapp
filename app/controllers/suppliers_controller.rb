class SuppliersController < ApplicationController
    def create
      @supplier = Supplier.new(supplier_params)
      @supplier.org_id = current_user.org_id
  
      if @supplier.save
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.append(
              "raw_material_stock_batch_supplier_id",
              partial: "suppliers/option",
              locals: { supplier: @supplier }
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
  