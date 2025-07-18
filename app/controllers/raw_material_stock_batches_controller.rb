class RawMaterialStockBatchesController < ApplicationController
  before_action :set_item_masters, only: [:new, :create]
  def new
    @batch = RawMaterialStockBatch.new
    @batch.raw_material_stock_items.build 
    @item_masters = ItemMaster.where(is_bom: false)
  end

  def show
    @batch = RawMaterialStockBatch.includes(:raw_material_stock_items).find(params[:id])
  end
  
  def update
    @raw_material_stock_batch = RawMaterialStockBatch.find(params[:id])
    if @raw_material_stock_batch.update(batch_params)
      redirect_to raw_material_stock_batches_path, notice: "Batch updated successfully."
    else
      render :edit
    end
  end
def create
  @batch = RawMaterialStockBatch.new(batch_params)

  if @batch.save
    @batch.raw_material_stock_items.each do |stock_item|
      item = ItemMaster.find_by(sku_id: stock_item.sku_id)
      if item
        previous_stock = item.opening_stock.to_i
        item.update(opening_stock: previous_stock + stock_item.receiving_quantity.to_i)
        item.versions.last.update!(source_type: "RawMaterialStockBatch", source_id: @batch.id)
      end
    end
    redirect_to raw_material_stock_batches_path, notice: "Raw material batch created successfully."
  else
    render :new, status: :unprocessable_entity
  end
end

  

  def index
    @batches = RawMaterialStockBatch.includes(:raw_material_stock_items).order(created_at: :desc)
    
  end

  private

  def set_item_masters
    @item_masters = ItemMaster.all
  end

  
  def batch_params
    params.require(:raw_material_stock_batch).permit(
      :supplier_name, :receiving_date, :supplier_invoice_number,
      raw_material_stock_items_attributes: [:id, :item_name, :sku_id, :receiving_quantity, :purchase_price, :item_master_id, :_destroy]
    )
  end
end
