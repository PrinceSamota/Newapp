class PurchaseOrdersController < ApplicationController
  before_action :set_purchase_order, only: [:edit, :update, :convert_to_rmi]

  def index
    @purchase_orders = PurchaseOrder.all.order(created_at: :desc)
    @purchase_order = PurchaseOrder.new
  end

  def new
    @purchase_order = PurchaseOrder.new
    @purchase_orders = PurchaseOrder.all.order(created_at: :desc)
  end

  def create
    @purchase_order = PurchaseOrder.new(purchase_order_params)
    @purchase_order.status = 'Open'
    @purchase_order.delivered_quantity = 0

    if @purchase_order.save
      redirect_to purchase_orders_path, notice: "Purchase Order created successfully."
    else
      @purchase_orders = PurchaseOrder.all.order(created_at: :desc)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @purchase_order.update(purchase_order_params)
      # Re-evaluate status based on new quantities if updated manually
      if @purchase_order.delivered_quantity >= @purchase_order.quantity
        @purchase_order.update(status: 'Closed')
      else
        @purchase_order.update(status: 'Open')
      end
      redirect_to purchase_orders_path, notice: "Purchase Order updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def convert_to_rmi
    quantity_to_convert = params[:quantity_to_convert].to_i
    receiving_date = params[:receiving_date]

    if quantity_to_convert <= 0
      redirect_to edit_purchase_order_path(@purchase_order), alert: "Quantity to convert must be greater than zero."
      return
    end

    if quantity_to_convert > @purchase_order.remaining_quantity
      redirect_to edit_purchase_order_path(@purchase_order), alert: "Quantity to convert cannot exceed the remaining quantity (#{@purchase_order.remaining_quantity})."
      return
    end

    if receiving_date.blank?
      redirect_to edit_purchase_order_path(@purchase_order), alert: "Receiving date is required."
      return
    end

    ActiveRecord::Base.transaction do
      # Create Raw Material Inward record
      RawMaterialInward.create!(
        supplier_name: @purchase_order.supplier_name,
        receiving_date: Date.parse(receiving_date),
        sku_id: @purchase_order.sku_id,
        item_name: @purchase_order.item_name,
        receiving_quantity: quantity_to_convert,
        purchase_price: @purchase_order.purchase_price,
        purchase_order_id: @purchase_order.id
      )

      # Update Purchase Order details
      new_delivered_quantity = @purchase_order.delivered_quantity + quantity_to_convert
      @purchase_order.delivered_quantity = new_delivered_quantity

      if new_delivered_quantity >= @purchase_order.quantity
        @purchase_order.status = 'Closed'
      end

      @purchase_order.save!
    end

    redirect_to edit_purchase_order_path(@purchase_order), notice: "Successfully converted #{quantity_to_convert} to Raw Material Inward."
  rescue => e
    redirect_to edit_purchase_order_path(@purchase_order), alert: "Failed to convert to RMI: #{e.message}"
  end

  private

  def set_purchase_order
    @purchase_order = PurchaseOrder.find(params[:id])
  end

  def purchase_order_params
    params.require(:purchase_order).permit(:po_number, :po_date, :supplier_name, :sku_id, :item_name, :quantity, :purchase_price)
  end
end
