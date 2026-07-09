class PurchaseOrdersController < ApplicationController
  before_action :set_purchase_order, only: [:edit, :update, :receive_item, :convert_receipt_to_rmi]
  before_action :set_item_masters_and_suppliers, only: [:index, :new, :create, :edit, :update]

  def index
    @q = PurchaseOrder.ransack(params[:q])
    @purchase_orders = @q.result.distinct.order(created_at: :desc)
    @purchase_order = PurchaseOrder.new
  end

  def new
    @purchase_order = PurchaseOrder.new
    @q = PurchaseOrder.ransack(params[:q])
    @purchase_orders = @q.result.distinct.order(created_at: :desc)
  end

  def create
    @purchase_order = PurchaseOrder.new(purchase_order_params)
    @purchase_order.status = 'Open'

    if @purchase_order.save
      redirect_to purchase_orders_path, notice: "Purchase Order created successfully."
    else
      @q = PurchaseOrder.ransack(params[:q])
      @purchase_orders = @q.result.distinct.order(created_at: :desc)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @po_items = @purchase_order.purchase_order_items
  end

  def update
    if @purchase_order.update(purchase_order_params)
      redirect_to purchase_orders_path, notice: "Purchase Order updated successfully."
    else
      @po_items = @purchase_order.purchase_order_items
      render :edit, status: :unprocessable_entity
    end
  end

  def receive_item
    quantity_to_convert = params[:quantity_to_convert].to_i
    receiving_date = params[:receiving_date]

    if quantity_to_convert <= 0
      redirect_to edit_purchase_order_path(@purchase_order), alert: "Quantity to receive must be greater than zero."
      return
    end

    if quantity_to_convert > @purchase_order.remaining_quantity
      redirect_to edit_purchase_order_path(@purchase_order), alert: "Quantity to receive cannot exceed the remaining quantity (#{@purchase_order.remaining_quantity})."
      return
    end

    if receiving_date.blank?
      redirect_to edit_purchase_order_path(@purchase_order), alert: "Receiving date is required."
      return
    end

    ActiveRecord::Base.transaction do
      RawMaterialInward.create!(
        purchase_order_id: @purchase_order.id,
        supplier_name: @purchase_order.supplier_name,
        receiving_date: Date.parse(receiving_date),
        sku_id: @purchase_order.sku_id,
        item_name: @purchase_order.item_name,
        receiving_quantity: quantity_to_convert,
        purchase_price: @purchase_order.purchase_price,
        converted_to_stock: false
      )

      # Update Purchase Order details
      new_delivered_quantity = @purchase_order.delivered_quantity + quantity_to_convert
      @purchase_order.delivered_quantity = new_delivered_quantity

      if new_delivered_quantity >= @purchase_order.quantity
        @purchase_order.status = 'Closed'
      end

      @purchase_order.save!
    end

    redirect_to edit_purchase_order_path(@purchase_order), notice: "Successfully recorded receipt of #{quantity_to_convert} items."
  rescue => e
    redirect_to edit_purchase_order_path(@purchase_order), alert: "Failed to record receipt: #{e.message}"
  end

  def convert_receipt_to_rmi
    receipt = RawMaterialInward.find(params[:receipt_id])
    
    if receipt.converted_to_stock
      redirect_to edit_purchase_order_path(@purchase_order), alert: "This receipt has already been converted to stock."
      return
    end

    ActiveRecord::Base.transaction do
      supplier = Supplier.find_by(name: @purchase_order.supplier_name)
      item = ItemMaster.find_by(sku_id: @purchase_order.sku_id)

      # Create or find Raw Material Stock Batch record
      batch = RawMaterialStockBatch.find_or_create_by!(
        supplier_invoice_number: @purchase_order.po_number,
        receiving_date: receipt.receiving_date
      ) do |b|
        b.supplier_id = supplier&.id
        b.purchase_order_id = @purchase_order.id
      end

      # Create Raw Material Stock Item record
      RawMaterialStockItem.create!(
        raw_material_stock_batch_id: batch.id,
        item_master_id: item&.id,
        receiving_quantity: receipt.receiving_quantity,
        purchase_price: receipt.purchase_price,
        sku_id: receipt.sku_id,
        item_name: receipt.item_name
      )

      # Mark receipt as converted
      receipt.update!(converted_to_stock: true)
    end

    redirect_to edit_purchase_order_path(@purchase_order), notice: "Successfully converted receipt to Raw Material Stock Batch."
  rescue => e
    redirect_to edit_purchase_order_path(@purchase_order), alert: "Failed to convert receipt: #{e.message}"
  end

  private

  def set_purchase_order
    @purchase_order = PurchaseOrder.find(params[:id])
  end

  def set_item_masters_and_suppliers
    @item_masters = ItemMaster.all
    @suppliers = Supplier.all
  end

  def purchase_order_params
    params.require(:purchase_order).permit(:po_number, :po_date, :supplier_name, :status, purchase_order_items_attributes: [:id, :sku_id, :item_name, :quantity, :purchase_price, :_destroy])
  end
end
