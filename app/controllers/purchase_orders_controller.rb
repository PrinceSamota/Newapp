class PurchaseOrdersController < ApplicationController
  before_action :set_purchase_order, only: [:edit, :update, :receive_item, :convert_receipt_to_rmi]
  before_action :set_item_masters_and_suppliers, only: [:index, :new, :create, :edit, :update]

  def index
    @q = PurchaseOrder.ransack(params[:q])
    @purchase_orders = @q.result.order(created_at: :desc)
    @purchase_order = PurchaseOrder.new
  end

  def new
    @purchase_order = PurchaseOrder.new
    @q = PurchaseOrder.ransack(params[:q])
    @purchase_orders = @q.result.order(created_at: :desc)
  end

  def create
    items = params.dig(:purchase_order, :items)

    if items.present?
      po_number = params[:purchase_order][:po_number]
      if PurchaseOrder.exists?(po_number: po_number)
        @purchase_order = PurchaseOrder.new(params.require(:purchase_order).permit(:po_number, :po_date, :supplier_name))
        @purchase_order.errors.add(:po_number, "has already been used")
        @q = PurchaseOrder.ransack(params[:q])
        @purchase_orders = @q.result.order(created_at: :desc)
        render :new, status: :unprocessable_entity
        return
      end

      success = true
      ActiveRecord::Base.transaction do
        items.each do |_, item_params|
          po = PurchaseOrder.new(
            po_number: params[:purchase_order][:po_number],
            po_date: params[:purchase_order][:po_date],
            supplier_name: params[:purchase_order][:supplier_name],
            sku_id: item_params[:sku_id],
            item_name: item_params[:item_name],
            quantity: item_params[:quantity],
            purchase_price: item_params[:purchase_price],
            status: 'Open',
            delivered_quantity: 0
          )
          unless po.save
            success = false
            @purchase_order = po # capture validation errors
            raise ActiveRecord::Rollback
          end
        end
      end

      if success
        redirect_to purchase_orders_path, notice: "Purchase Orders created successfully."
      else
        @q = PurchaseOrder.ransack(params[:q])
        @purchase_orders = @q.result.order(created_at: :desc)
        render :new, status: :unprocessable_entity
      end
    else
      @purchase_order = PurchaseOrder.new(purchase_order_params)
      @purchase_order.status = 'Open'
      @purchase_order.delivered_quantity = 0

      if PurchaseOrder.exists?(po_number: @purchase_order.po_number)
        @purchase_order.errors.add(:po_number, "has already been used")
        @q = PurchaseOrder.ransack(params[:q])
        @purchase_orders = @q.result.order(created_at: :desc)
        render :new, status: :unprocessable_entity
        return
      end

      if @purchase_order.save
        redirect_to purchase_orders_path, notice: "Purchase Order created successfully."
      else
        @q = PurchaseOrder.ransack(params[:q])
        @purchase_orders = @q.result.order(created_at: :desc)
        render :new, status: :unprocessable_entity
      end
    end
  end

  def edit
    @po_items = PurchaseOrder.where(po_number: @purchase_order.po_number).order(:id)
  end

  def update
    items = params.dig(:purchase_order, :items)
    po_number = params[:purchase_order][:po_number]
    po_date = params[:purchase_order][:po_date]
    supplier_name = params[:purchase_order][:supplier_name]

    if items.present?
      success = true
      submitted_item_ids = []

      ActiveRecord::Base.transaction do
        items.each do |_, item_params|
          if item_params[:id].present?
            item = PurchaseOrder.find(item_params[:id])
            if item.update(
                 po_number: po_number,
                 po_date: po_date,
                 supplier_name: supplier_name,
                 sku_id: item_params[:sku_id],
                 item_name: item_params[:item_name],
                 quantity: item_params[:quantity],
                 purchase_price: item_params[:purchase_price]
               )
              # Re-evaluate status based on new quantities
              item.update!(status: item.delivered_quantity >= item.quantity ? 'Closed' : 'Open')
              submitted_item_ids << item.id
            else
              success = false
              @purchase_order = item
              raise ActiveRecord::Rollback
            end
          else
            po = PurchaseOrder.new(
              po_number: po_number,
              po_date: po_date,
              supplier_name: supplier_name,
              sku_id: item_params[:sku_id],
              item_name: item_params[:item_name],
              quantity: item_params[:quantity],
              purchase_price: item_params[:purchase_price],
              status: 'Open',
              delivered_quantity: 0
            )
            if po.save
              submitted_item_ids << po.id
            else
              success = false
              @purchase_order = po
              raise ActiveRecord::Rollback
            end
          end
        end

        if success
          # Delete items removed from the form if they haven't been received
          PurchaseOrder.where(po_number: @purchase_order.po_number)
                       .where.not(id: submitted_item_ids)
                       .each do |missing_item|
            if missing_item.delivered_quantity == 0
              missing_item.destroy
            end
          end
        end
      end

      if success
        redirect_to purchase_orders_path, notice: "Purchase Order updated successfully."
      else
        @po_items = PurchaseOrder.where(po_number: @purchase_order.po_number).order(:id)
        @item_masters = ItemMaster.all
        @suppliers = Supplier.all
        render :edit, status: :unprocessable_entity
      end
    else
      redirect_to edit_purchase_order_path(@purchase_order), alert: "No items provided."
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
    params.require(:purchase_order).permit(:po_number, :po_date, :supplier_name, :sku_id, :item_name, :quantity, :purchase_price)
  end
end
