class RawMaterialStockBatchesController < ApplicationController
  before_action :set_item_masters, only: [:new, :create]
  def new
    @batch = RawMaterialStockBatch.new
    @batch.raw_material_stock_items.build 
    @item_masters = ItemMaster.all
  end

  def create
    @batch = RawMaterialStockBatch.new(batch_params)
  
    if @batch.save
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
