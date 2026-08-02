class RawMaterialStockBatchesController < ApplicationController
  before_action :set_item_masters, only: [:new, :create]
  def new
    @batch = RawMaterialStockBatch.new
    @item_masters = ItemMaster.all
    @selected_supplier_id = params[:supplier_id]

    if params[:po_number].present?
      po = PurchaseOrder.find_by(po_number: params[:po_number])
      if po
        @batch.purchase_order_id = po.id
        @batch.supplier_id = Supplier.find_by(name: po.supplier_name)&.id
        @selected_supplier_id = @batch.supplier_id
        @batch.receiving_date = po.po_date || Date.today

        po.purchase_order_items.each do |po_item|
          item = @batch.raw_material_stock_items.build(
            sku_id: po_item.sku_id,
            item_name: po_item.item_name,
            purchase_price: po_item.purchase_price
          )
          item.po_remaining_quantity = po_item.remaining_quantity
        end
      else
        @batch.raw_material_stock_items.build
      end
    else
      @batch.raw_material_stock_items.build
    end
  end

  def show
    @batch = RawMaterialStockBatch.includes(:raw_material_stock_items).find(params[:id])
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Purchase_Order_#{@batch.purchase_order&.po_number || @batch.id}",
               template: "raw_material_stock_batches/pdf",
               layout: "pdf",
               formats: [:html]
      end
    end
  end
  
  def update
    @raw_material_stock_batch = RawMaterialStockBatch.find(params[:id])
    if @raw_material_stock_batch.update(batch_params)
      if params[:update_item_id].present?
        stock_item = @raw_material_stock_batch.raw_material_stock_items.find_by(id: params[:update_item_id])
        if stock_item && !stock_item.stock_updated?
          if stock_item.po_invoice.blank?
            redirect_to raw_material_stock_batch_path(@raw_material_stock_batch), alert: "PO Invoice is required to update stock for #{stock_item.sku_id}."
            return
          end
          
          item = ItemMaster.find_by(sku_id: stock_item.sku_id)
          if item
            previous_stock = item.opening_stock.to_i
            
            # Set PaperTrail request parameters
            PaperTrail.request.whodunnit = current_user&.id if defined?(current_user)
            PaperTrail.request.controller_info = { reason: "RMI Update Stock: #{@raw_material_stock_batch.id}" } if PaperTrail.request.respond_to?(:controller_info=)
            
            item.update!(opening_stock: previous_stock + stock_item.receiving_quantity.to_i)
            if item.versions.last
              item.versions.last.update!(source_type: "RawMaterialStockBatch", source_id: @raw_material_stock_batch.id)
            end
            
            stock_item.update!(stock_updated: true)
          end
        end
        redirect_to raw_material_stock_batch_path(@raw_material_stock_batch), notice: "Stock updated successfully for #{stock_item&.sku_id}."
      else
        if @raw_material_stock_batch.purchase_order_id.blank?
          @raw_material_stock_batch.raw_material_stock_items.where(stock_updated: false).each do |stock_item|
            item = ItemMaster.find_by(sku_id: stock_item.sku_id)
            if item
              previous_stock = item.opening_stock.to_i
              PaperTrail.request.whodunnit = current_user&.id if defined?(current_user)
              PaperTrail.request.controller_info = { reason: "RMI Update Stock: #{@raw_material_stock_batch.id}" } if PaperTrail.request.respond_to?(:controller_info=)
              
              item.update!(opening_stock: previous_stock + stock_item.receiving_quantity.to_i)
              if item.versions.last
                item.versions.last.update!(source_type: "RawMaterialStockBatch", source_id: @raw_material_stock_batch.id)
              end
              stock_item.update!(stock_updated: true)
            end
          end
        end
        redirect_to raw_material_stock_batch_path(@raw_material_stock_batch), notice: "Batch updated successfully."
      end
    else
      render :show 
    end
  end
def create
  @batch = RawMaterialStockBatch.new(batch_params)

  if @batch.save
    if @batch.purchase_order_id.present?
      @batch.raw_material_stock_items.each do |stock_item|
        item = ItemMaster.find_by(sku_id: stock_item.sku_id)
        if item
          previous_stock = item.opening_stock.to_i
          item.update(opening_stock: previous_stock + stock_item.receiving_quantity.to_i)
          if item.versions.last
            item.versions.last.update!(source_type: "RawMaterialStockBatch", source_id: @batch.id)
          end
          stock_item.update!(stock_updated: true)
        end
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
  @batches = @q.result.includes(:supplier, :raw_material_stock_items).order(created_at: :desc).paginate(page: params[:page], per_page: 100)

  respond_to do |format|
    format.html
    format.xlsx do
      @batches_all = RawMaterialStockBatch.includes(:supplier).all
      response.headers['Content-Disposition'] =
        "attachment; filename=\"raw_material_inward_#{Date.today}.xlsx\""
    end
  end
end

  private

  def set_item_masters
    @item_masters = ItemMaster.all
  end

  
  def batch_params
    params.require(:raw_material_stock_batch).permit(
      :supplier_id, :receiving_date, :supplier_invoice_number, :purchase_order_id,
      raw_material_stock_items_attributes: [:id, :item_name, :sku_id, :receiving_quantity, :purchase_price, :item_master_id, :po_invoice, :stock_updated, :_destroy]
    )
  end
end
