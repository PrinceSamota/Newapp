class DispatchesController < ApplicationController
  def index
    @q = Dispatch.ransack(params[:q])
    dispatches = @q.result(distinct: true)

    if params[:q].present? && params[:q][:search_all_cont].present?
      search_term = params[:q][:search_all_cont].strip
      
      if search_term.match?(/^\d+$/) || search_term.match?(/^S\d+$/)
        serial_results = Dispatch.with_serial_in_range(search_term)
        dispatch_ids = dispatches.pluck(:id) + serial_results.pluck(:id)
        dispatches = Dispatch.where(id: dispatch_ids.uniq)
      end
    end

    @dispatches = dispatches.order(created_at: :desc).paginate(page: params[:page], per_page: 100)
    @dispatch = Dispatch.new

    respond_to do |format|
      format.html
      format.xlsx do
        @dispatches_all = dispatches.includes(dispatch_items: { order_entry: [:client, :location, :driver_revision] })
        response.headers['Content-Disposition'] =
          "attachment; filename=\"dispatches-#{Date.today}.xlsx\""
      end
    end
  end
  
  

  def new
    @dispatch = Dispatch.new
    @dispatch.dispatch_items.build

    used_order_entry_ids = DispatchItem.where.not(order_entry_id: nil).pluck(:order_entry_id)

    @order_entries = OrderEntry.where.not(id: used_order_entry_ids)
   
  end

  def create
    @dispatch = Dispatch.new(dispatch_params)
  
    if @dispatch.save
      @dispatch.dispatch_items.each do |item|
        order = item.order_entry
        order.update(dispatch_no: @dispatch.d_id) if order.present?
      end
      @dispatches = Dispatch.all.order(created_at: :desc) 
      redirect_to dispatches_path, notice: "BOM created successfully"
      
    
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @dispatch = Dispatch.find(params[:id])
  
    if @dispatch.dispatch_items.empty?
      @dispatch.dispatch_items.build
    end
  
    current_order_entry_ids = @dispatch.dispatch_items.pluck(:order_entry_id).compact
  
    used_order_entry_ids = DispatchItem
                             .where.not(order_entry_id: nil)
                             .where.not(order_entry_id: current_order_entry_ids)
                             .pluck(:order_entry_id)
  
    @order_entries = OrderEntry.where.not(id: used_order_entry_ids)
  
    @input = Input.find_by(dispatch_id: @dispatch.id)
  end
  
  def update
    @dispatch = Dispatch.find(params[:id])

    removed_item_ids = dispatch_params_update[:dispatch_items_attributes]
    &.to_h
    &.select { |_, item| item[:_destroy] == '1' }
    &.map { |_, item| item[:id].to_i } || []

    ActiveRecord::Base.transaction do
      removed_item_ids.each do |item_id|
        item = @dispatch.dispatch_items.find_by(id: item_id)
        next unless item && item.order_entry.present?

        item.order_entry.update(dispatch_no: nil)
      end

      if @dispatch.update(dispatch_params_update)
        @dispatch.dispatch_items.each do |item|
          order = item.order_entry
          order.update(dispatch_no: @dispatch.d_id) if order.present?
        end

        if @dispatch.progress == "Dispatched" && @dispatch.progress_previously_changed?
          PaperTrail.request(controller_info: {
            source_type: "Dispatch",
            source_id: @dispatch.id
          }) do
            @dispatch.dispatch_items.each do |item|
              order = item.order_entry
              if order.present?
                item_master = ItemMaster.find_by(sku_id: order.sku_number)
                if item_master.present?
                  item_master.opening_stock -= order.qty.to_f
                  item_master.save!
                else
                  raise ActiveRecord::Rollback, "ItemMaster not found for SKU #{order.sku_number}"
                end
              else
                raise ActiveRecord::Rollback, "OrderEntry not found for Order No #{item.order_no}"
              end
            end
          end
        end

        redirect_to dispatches_path, notice: "Dispatch updated and stock adjusted."
      else
        flash.now[:alert] = @dispatch.errors.full_messages.join(", ")
        render :edit, status: :unprocessable_entity
      end
    end
  end
  
  def order_details
    @order_entry = OrderEntry.find_by(id: params[:order_entry_id])
    item_master = ItemMaster.find_by(sku_id: @order_entry.sku_number)
    respond_to do |format|
      format.html { render partial: "dispatches/order_details", locals: { order: @order_entry, item_master: item_master } }
      format.turbo_stream { render partial: "dispatches/order_details", formats: [:html], locals: { order: @order_entry, item_master: item_master } }
    end
    
  end
  

  def new_item_row
    @dispatch_item = DispatchItem.new
    @index = params[:index].to_i
  
    used_order_entry_ids = DispatchItem
                             .where.not(order_entry_id: nil)
                             .pluck(:order_entry_id)
  
    @order_entries = OrderEntry
                       .where.not(id: used_order_entry_ids)
                       .select(:id, :order_no, :sku_number)
                       .distinct
  
    render partial: "dispatches/dispatch_item_fields",
           locals: {
             dispatch_item: @dispatch_item,
             index: @index,
             from_edit: false
           }
  end

  def new_item_row_edit
    @index = params[:index].to_i
    @dispatch_item = DispatchItem.new
    @from_edit = params[:from_edit] == "true"
    render partial: "dispatches/dispatch_item_fields", locals: { dispatch_item: @dispatch_item, index: @index, from_edit: @from_edit }
  end

  def download_pdf
    @dispatch = Dispatch.find(params[:id])
  
    respond_to do |format|
      format.pdf do
        render pdf: "dispatch_#{@dispatch.id}",
               template: "dispatches/pdf",
               layout: "pdf", 
               formats: [:html],
               encoding: "UTF-8",
               show_as_html: params.key?('debug')
      end
    end
  end
  
  private

  def dispatch_params
    params.require(:dispatch).permit(
      :location_id,
      :dispatch_date,
      :delivery_date,
      :courier_company,
      :mode_of_shipment,
      :d_id,
      :track_no,
      :progress,
      :invoice_no,
      :color,
      dispatch_items_attributes: [:id, :order_no, :order_entry_id, :quantity, :_destroy]
    )
  end
  def dispatch_params_update
    params.require(:dispatch).permit(
      :location_id,
      :dispatch_date,
      :delivery_date,
      :courier_company,
      :mode_of_shipment,
      :d_id,
      :track_no,
      :progress,
      :invoice_no,
      :color,
      dispatch_items_attributes: [:id, :order_no, :order_entry_id, :quantity, :_destroy]
    )
  end
end
