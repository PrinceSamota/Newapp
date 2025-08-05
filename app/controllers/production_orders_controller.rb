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
  
    first_item = clean_params[:production_order_items_attributes]&.values&.first
    clean_params[:item_master_id] = first_item[:item_master_id] if first_item.present?
  
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
    @quantity = params[:quantity].to_f
  
    @bom_ids = @p_items.flat_map { |item| JSON.parse(item.bom_ids || "[]") rescue [] }.uniq
    @boms = BillOfMaterial.where(id: @bom_ids)
  
    @bom_to_item_map = {}
    @insufficient_stock_bom_ids = []
  
    @p_items.each do |item|
      (JSON.parse(item.bom_ids || "[]") rescue []).each do |bom_id|
        @bom_to_item_map[bom_id.to_i] = item
      end
    end
  
    # Check insufficient stock for each BOM
    @boms.each do |bom|
      bom.bom_raw_material_items.each do |rm|
        required_quantity = rm.quantity.to_f * @quantity
    
        # Fetch current stock from ItemMaster using SKU
        item = ItemMaster.find_by(sku_id: rm.sku_id)
        current_stock = item&.opening_stock.to_f
    
        if current_stock < required_quantity
          @insufficient_stock_bom_ids << bom.id
          break
        end
      end
    end
  end
  
  def destroy
    @production_order = ProductionOrder.find(params[:id])
    @production_order.destroy
    redirect_to production_orders_path, notice: "Production Order deleted successfully."
  end
  def index
    @q = ProductionOrder
           .includes(production_order_items: :item_master)
           .order(created_at: :desc)
           .ransack(params[:q])
    @production_orders = @q.result(distinct: true).paginate(page: params[:page], per_page: 100)
  end
  
  
  def show
    @production_order = ProductionOrder.find(params[:id])
  end

  private

  def production_order_params
    params.require(:production_order).permit(
      :item_master_id,
      production_order_items_attributes: [:id, :sku_id, :item_name, :current_stock, :quantity, :bom, :stage, :item_master_id,  :_destroy, bom_ids: [] ]
    )
  end
end
