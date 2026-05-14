class OrderEntriesController < ApplicationController
  require 'ostruct'
    def new
        @order_entry = OrderEntry.new
        @item_masters = ItemMaster.includes(:raw_material_stock_items,:category,:measurement,:fuse_type,:loop,:item_type,:profile,:wattage,:voltage,:length,:cct,:cover_type,:extra).all
        @item_articles = ItemMaster.pluck(:article_number).compact.uniq
      end
      
      def manual_decode
        @article_number = params[:article_number]
        decoded_data = ArticleDecoder.new(@article_number).decode
        @decoded = OpenStruct.new(decoded_data)
        @order_entry = OrderEntry.new
        @item_masters = ItemMaster.all
        render :new
      end

      def check_duplicate
        exists = OrderEntry.exists?(
          order_no: params[:order_no],
          client_id: params[:client_id],
          article_no: params[:article_no]
        )
        render json: { exists: exists }
      end

    def create
      @order_entry = OrderEntry.new(order_entry_params)
      decode_article_fields

      if @order_entry.save
        redirect_to order_entries_path, notice: "Order entry created successfully."
      else
        @item_masters = ItemMaster.includes(:raw_material_stock_items,:category,:measurement,:fuse_type,:loop,:item_type,:profile,:wattage,:voltage,:length,:cct,:cover_type,:extra).all
        @item_articles = ItemMaster.pluck(:article_number).compact.uniq
        render :new, status: :unprocessable_entity
      end
    end

    def index
      dispatched_order_entry_ids = DispatchItem
        .joins(:dispatch)
        .where(dispatches: { progress: 'Dispatched' })
        .pluck(:order_entry_id)
        .uniq

      @q = OrderEntry
        .visible_in_index
        .includes(:client)
        .left_joins(dispatch_items: :dispatch)
        .where.not(id: dispatched_order_entry_ids)
        .select('order_entries.*, MIN(dispatches.d_id) AS dispatch_d_id') 
        .group('order_entries.id') 
        .ransack(params[:q].presence || {})
    
        
      @all_filtered_orders = @q.result.order(params.dig(:q, :s) || 'dispatch_no ASC')

      @order_entries = @all_filtered_orders.paginate(page: params[:page], per_page: 100)
    

      digit_color_map = {
        '1' => '#FFB3B3',  # Light Red
        '2' => '#B3D1FF',  # Light Blue
        '3' => '#B3FFB3',  # Light Green
        '4' => '#FFFFB3',  # Light Yellow
        '5' => '#FFD9B3',  # Light Orange
        '6' => '#D1B3FF',  # Light Purple
        '7' => '#FFB3FF',  # Light Magenta
        '8' => '#D2B48C',  # Light Brown (Tan)
        '9' => '#FFD6E7',  # Light Pink
        '0' => '#D3D3D3'   # Light Gray
      }


      @dispatch_color_map = {}

      @order_entries.each do |order|
        dispatch_no = order.dispatch_no&.strip
        next unless dispatch_no.present?  

        last_digit = dispatch_no[-1]  

        if digit_color_map.key?(last_digit)
          @dispatch_color_map[dispatch_no] = digit_color_map[last_digit]
        else
          @dispatch_color_map[dispatch_no] = '#000000' 
        end
      end
      if session[:cart].present?
        @cart_orders = OrderEntry.where(id: session[:cart])
      else
        @cart_orders = []
      end
      @dispatch = Dispatch.new
      @cart_orders.each do |order|
        @dispatch.dispatch_items.build(order_entry_id: order.id, quantity: 1)
      end

      respond_to do |format|
        format.html
        format.xlsx do
          response.headers['Content-Disposition'] =
            "attachment; filename=\"pending_orders_#{Date.today}.xlsx\""
        end
      end
      
    end
    
  
  
    def show
      @order_entry = OrderEntry.with_deleted.find(params[:id])
      @item_masters = ItemMaster.all
    end
    def edit
      @order_entry = OrderEntry.with_deleted.find(params[:id])
      @item_masters = ItemMaster.includes(:raw_material_stock_items,:category,:measurement,:fuse_type,:loop,:item_type,:profile,:wattage,:voltage,:length,:cct,:cover_type,:extra).all
      @item_articles = ItemMaster.pluck(:article_number).compact.uniq
    end
    def update
      @order_entry = OrderEntry.with_deleted.find(params[:id])
      
      if @order_entry.deleted_at.present?
        redirect_to @order_entry, alert: "Cannot update deleted order."
        return
      end
      
      if @order_entry.update(order_entry_params_upload)
        redirect_to order_entries_path, notice: "Order updated successfully."
      else
        render :show
      end
    end

    def archive
      @order_entry = OrderEntry.find(params[:id])
      @order_entry.destroy 
      
      respond_to do |format|
        format.html { redirect_to order_entries_path, notice: "Order archived successfully." }
        format.js { 
          flash.now[:notice] = "Order archived successfully."
          render js: "
            document.querySelector('tr[data-order-id=\"#{@order_entry.id}\"]').style.display = 'none';
            alert('Order archived successfully!');
          "
        }
      end
    end

    def generate_qr_links
      @order_entry = OrderEntry.with_deleted.find(params[:id])
      @links = []
      
      start_sno = @order_entry.start_serial_no.to_i
      end_sno = @order_entry.end_serial_no.to_i
      
      if start_sno > 0 && end_sno >= start_sno
        fg = FinishedGood.find_by(sku_id: @order_entry.sku_number)
        bom = fg&.bill_of_material
        bom_items = bom ? bom.bom_raw_material_items.includes(:item_master) : []
        sub_boms = bom_items.select { |item| item.item_master&.is_bom? }
        
        (start_sno..end_sno).each do |sno|
          if sub_boms.empty?
            @links << serial_number_url(id: sno)
          else
            unit_counter = 1
            sub_boms.each do |sub_bom|
              qty = sub_bom.quantity.to_i
              qty.times do
                @links << serial_number_url(id: "#{sno}_#{unit_counter}")
                unit_counter += 1
              end
            end
          end
        end
      end
    end

    private
  
    def order_entry_params
      params.require(:order_entry).permit(
        :order_no,
        :article_no,        
        :client_id,
        :target_date,
        :location_id,
        :qty,
        :sku_number,
        :fuse_type,
        :loop,
        :item_type,
        :profile,
        :wattage,
        :voltage,
        :length,
        :cct,
        :cover_type,
        :status,
        :remark,
        :extra,
        :generate_sno
      )
    end
    def order_entry_params_upload
      params.require(:order_entry).permit(
        :order_no,
        :article_no,
        :client_id,
        :target_date,
        :location_id,
        :qty,
        :sku_number,
        :fuse_type,
        :loop,
        :item_type,
        :profile,
        :wattage,
        :voltage,
        :length,
        :cct,
        :cover_type,
        :start_serial_no,
        :end_serial_no,
        :mfg_date,
        :order_receiving_date,
        :driver_revision_id,
        :invoice_no,
        :tracking_no,
        :dispatch_no,
        :status,
        :box,
        :extra,
        :remark,
        :generate_sno
      )
    end
    
    def decode_article_fields
      decoded = ArticleDecoder.new(@order_entry.article_no).decode
    
      allowed_keys = %i[ptype profile voltage wattage length cct cover_type]
      allowed_keys.each do |key|
        if decoded[key].present? && @order_entry.send(key).blank?
          @order_entry.send("#{key}=", decoded[key])
        end
      end
    end
    

  end
  
