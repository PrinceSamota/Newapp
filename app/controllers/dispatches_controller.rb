class DispatchesController < ApplicationController
  def index
    @dispatches = Dispatch.order(created_at: :desc).paginate(page: params[:page], per_page: 30)
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
    if @dispatch.dispatch_items.empty?
      @dispatch.dispatch_items.build
    end
  end
  
  def update
    @dispatch = Dispatch.find(params[:id])
  
    ActiveRecord::Base.transaction do
      if @dispatch.update(dispatch_params_update)
  
        if @dispatch.progress == "Dispatched"
          PaperTrail.request(controller_info: {
            source_type: "Dispatch",
            source_id: @dispatch.id
          }) do
            @dispatch.dispatch_items.each do |item|
              order = OrderEntry.find_by(order_no: item.order_no)
              if order.present?
                item_master = ItemMaster.find_by(sku_id: order.sku_number)
                if item_master.present?
                  item_master.opening_stock -= order.qty.to_f
                  item_master.save!
                else
                  raise ActiveRecord::Rollback, "ItemMaster not found for SKU #{order.sku_number}"
                end
              else
                raise ActiveRecord::Rollback, "OrderEntry not found for Order No #{item.order_no}"
              end
            end
          end
        end
  
        redirect_to dispatches_path, notice: "Dispatch updated and stock adjusted."
      else
        render :edit
      end
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
      :location_id,
      :dispatch_date,
      :delivery_date,
      :courier_company,
      :mode_of_shipment,
      :d_id,
      :track_no,
      :progress,
      dispatch_items_attributes: [:id, :order_no, :quantity, :_destroy]
    )
  end
  def dispatch_params_update
    params.require(:dispatch).permit(
      :location_id,
      :dispatch_date,
      :delivery_date,
      :courier_company,
      :mode_of_shipment,
      :d_id,
      :track_no,
      :progress,
      :invoice_no,
      dispatch_items_attributes: [:id, :order_no, :quantity, :_destroy]
    )
  end
end
