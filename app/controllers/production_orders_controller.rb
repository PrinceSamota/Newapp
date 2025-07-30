class ProductionOrdersController < ApplicationController
  def new
    @production_order = ProductionOrder.new
    @production_order.production_order_items.build
    @item_masters = ItemMaster.all
  end
  
  def create
    clean_params = production_order_params
    clean_params[:production_order_items_attributes]&.each do |_, item_attrs|
      if item_attrs[:bom_ids].is_a?(Array)
        item_attrs[:bom_ids] = item_attrs[:bom_ids].reject(&:blank?).to_json
      end
    end
  
    @production_order = ProductionOrder.new(clean_params)
  
    if @production_order.save
      redirect_to production_orders_path, notice: "Production order created successfully."
    else
      @item_masters = ItemMaster.all
      render :new, status: :unprocessable_entity
    end
  end
  
  def bom_details
    @production_order = ProductionOrder.find(params[:id])
    @p_items = @production_order.production_order_items.includes(:production_order)
    @quantity = params[:quantity]
  
    # Flatten all BOM IDs from all items
    @bom_ids = @p_items.flat_map do |item|
      JSON.parse(item.bom_ids || "[]") rescue []
    end.uniq
  
    @boms = BillOfMaterial.where(id: @bom_ids)
  
    # Create a mapping from BOM ID to its associated ProductionOrderItem
    @bom_to_item_map = {}
    @p_items.each do |item|
      (JSON.parse(item.bom_ids || "[]") rescue []).each do |bom_id|
        @bom_to_item_map[bom_id.to_i] = item
      end
    end
  end
  

  def index
    @production_orders = ProductionOrder.includes(:production_order_items).order(created_at: :desc).paginate(page: params[:page], per_page: 30)
  end
  def show
    @production_order = ProductionOrder.find(params[:id])
  end

  private

  def production_order_params
    params.require(:production_order).permit(
      production_order_items_attributes: [:id, :sku_id, :item_name, :current_stock, :quantity, :bom, :stage,  :_destroy, bom_ids: [] ]
    )
  end
end
