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
      @item_masters = ItemMaster.includes(:raw_material_stock_items,:category,:measurement,:fuse_type,:loop,:item_type,:profile,:wattage,:voltage,:length,:cct,:cover_type,:extra).all
      @item_articles = ItemMaster.pluck(:article_number).compact.uniq
      @links = []
      
      start_sno = @order_entry.start_serial_no.to_s.gsub(/\D/, '').to_i
      end_sno = @order_entry.end_serial_no.to_s.gsub(/\D/, '').to_i
      
      if start_sno > 0 && end_sno >= start_sno
        fg = FinishedGood.find_by(sku_id: @order_entry.sku_number)
        bom = fg&.bill_of_material
        bom_items = bom ? bom.bom_raw_material_items.includes(:item_master) : []
        sub_boms = bom_items.select { |item| item.item_master&.is_bom? }
        
        (start_sno..end_sno).each do |sno|
          parent_link = {
            url: serial_number_url(id: sno),
            article_no: @order_entry.article_no.presence || "N/A",
            type: :parent,
            sno: sno.to_s
          }
          
          children = []
          unless sub_boms.empty?
            unit_counter = 1
            sub_boms.each do |sub_bom|
              qty = sub_bom.quantity.to_i
              qty.times do
                im_id = sub_bom.item_master&.id
                sno_key = "#{sno}_#{unit_counter}"
                mapped_article = @order_entry.qr_links_map&.[](sno_key) || @order_entry.qr_links_map&.[](im_id.to_s)
                children << {
                  url: serial_number_url(id: sno_key),
                  sno: sno_key,
                  article_no: mapped_article.presence || sub_bom.item_master&.article_number.presence || "N/A",
                  type: :component,
                  item_master_id: im_id
                }
                unit_counter += 1
              end
            end
          end
          
          @links << {
            parent: parent_link,
            children: children
          }
        end
      end

      respond_to do |format|
        format.html
        format.json do
          flat_links = []
          @links.each do |group|
            flat_links << {
              link: group[:parent][:url],
              article_number: group[:parent][:article_no],
              parent_link: nil,
              parent_article_number: nil,
              type: "parent"
            }
            group[:children].each do |child|
              flat_links << {
                link: child[:url],
                article_number: child[:article_no],
                parent_link: group[:parent][:url],
                parent_article_number: group[:parent][:article_no],
                type: "component",
                sno: child[:sno]
              }
            end
          end
          render json: flat_links
        end
      end
    end

    def update_article_link
      @order_entry = OrderEntry.with_deleted.find(params[:id])
      
      if params[:serial_no].present?
        serial_no = params[:serial_no]
        article_no = params[:article_no]
        
        map = (@order_entry.qr_links_map || {}).dup
        map[serial_no] = article_no
        @order_entry.qr_links_map = map
        
        if @order_entry.save
          notice_msg = "Component article linked successfully for serial number #{serial_no}."
        else
          alert_msg = "Failed to link component article: #{@order_entry.errors.full_messages.join(', ')}"
        end
      elsif params[:item_master_id].present?
        item_master_id = params[:item_master_id]
        article_no = params[:article_no]
        
        map = (@order_entry.qr_links_map || {}).dup
        map.keys.each do |key|
          map.delete(key) if key.include?('_')
        end
        map[item_master_id.to_s] = article_no
        @order_entry.qr_links_map = map
        
        if @order_entry.save
          notice_msg = "Component article linked successfully for all child components."
        else
          alert_msg = "Failed to link component article: #{@order_entry.errors.full_messages.join(', ')}"
        end
      else
        @order_entry.article_no = params[:article_no]
        decoded = ArticleDecoder.new(params[:article_no]).decode
        allowed_keys = %i[ptype profile voltage wattage length cct cover_type]
        allowed_keys.each do |key|
          if decoded[key].present?
            @order_entry.send("#{key}=", decoded[key])
          end
        end
        
        if @order_entry.save
          notice_msg = "Parent article updated successfully."
        else
          alert_msg = "Failed to update parent article: #{@order_entry.errors.full_messages.join(', ')}"
        end
      end
      
      if alert_msg.present?
        redirect_to generate_qr_links_order_entry_path(@order_entry), alert: alert_msg
      else
        redirect_to generate_qr_links_order_entry_path(@order_entry), notice: notice_msg
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
  
