class RawMaterialStockBatchesController < ApplicationController
  before_action :set_item_masters, only: [:new, :create]
  def new
    @batch = RawMaterialStockBatch.new
    @batch.raw_material_stock_items.build 
    @item_masters = ItemMaster.where('"item_masters"."is_bom" = ?', false)
    @selected_supplier_id = params[:supplier_id]
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
    @item_masters = ItemMaster.all
  
  @batch.raw_material_stock_items.build if @batch.raw_material_stock_items.empty?

  render :new, status: :unprocessable_entity
  end
end

  

def index
  @q = RawMaterialStockBatch.ransack(params[:q])
  @batches = @q.result.includes(:supplier, :raw_material_stock_items).order(created_at: :desc).paginate(page: params[:page], per_page: 30)
end

  private

  def set_item_masters
    @item_masters = ItemMaster.all
  end

  
  def batch_params
    params.require(:raw_material_stock_batch).permit(
      :supplier_id, :receiving_date, :supplier_invoice_number,
      raw_material_stock_items_attributes: [:id, :item_name, :sku_id, :receiving_quantity, :purchase_price, :item_master_id, :_destroy]
    )
  end
end
