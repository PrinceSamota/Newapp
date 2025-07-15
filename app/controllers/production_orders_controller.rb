class ProductionOrdersController < ApplicationController
  def new
    @production_order = ProductionOrder.new
    @production_order.production_order_items.build
    @item_masters = ItemMaster.where(is_bOM: true)
  end
  
  def create
    @production_order = ProductionOrder.new(production_order_params)
  
    if @production_order.save
      @production_order.production_order_items.each do |item|
        item_master = ItemMaster.find_by(sku_id: item.sku_id)
        if item_master
          previous_stock = item_master.opening_stock.to_i
          item_master.update(opening_stock: previous_stock - item.quantity.to_i)
          item_master.versions.last.update!(source_type: "ProductionOrder", source_id: @production_order.id)
        end
      end
      redirect_to production_orders_path, notice: "Production order created successfully."
    else
      @item_masters = ItemMaster.where(is_bOM: true)
      render :new, status: :unprocessable_entity  
    end
  end
  
  
  def index
    @production_orders = ProductionOrder.includes(:production_order_items).order(created_at: :desc)
  end
  def show
    @production_order = ProductionOrder.find(params[:id])
  end

  private

  def production_order_params
    params.require(:production_order).permit(
      production_order_items_attributes: [:id, :sku_id, :item_name, :current_stock, :quantity, :bom, :_destroy]
    )
  end
end
