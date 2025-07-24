class DispatchesController < ApplicationController
  def index
    @dispatches = Dispatch.order(created_at: :desc)
    @dispatch = Dispatch.new
   
  end

  def new
    @dispatch = Dispatch.new
    @dispatch.dispatch_items.build
   
  end

  def create
    @dispatch = Dispatch.new(dispatch_params)
  
    if @dispatch.save
      @dispatches = Dispatch.all.order(created_at: :desc) # ✅ add this
      redirect_to dispatches_path, notice: "BOM created successfully"
      
    
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @dispatch = Dispatch.find(params[:id])
    @dispatch.dispatch_items.build if @dispatch.dispatch_items.empty?
  end

  def update
    @dispatch = Dispatch.find(params[:id])
    if @dispatch.update(dispatch_params)
      redirect_to dispatches_path, notice: "Dispatch updated successfully."
    else
      render :edit
    end
  end
  def new_item_row
    @dispatch_item = DispatchItem.new
    @index = params[:index].to_i
    render partial: 'dispatches/dispatch_item_fields', locals: { dispatch_item: @dispatch_item, index: @index }
  end
  private

  def dispatch_params
    params.require(:dispatch).permit(
      :client_id,
      :dispatch_date,
      :delivery_date,
      :courier_company,
      :mode_of_shipment,
      dispatch_items_attributes: [:id, :order_no, :quantity, :_destroy]
    )
  end
end
