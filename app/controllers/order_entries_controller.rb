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
    def create
      @order_entry = OrderEntry.new(order_entry_params)
      decode_article_fields
  
      if @order_entry.save
        redirect_to order_entries_path, notice: "Order entry created successfully."
      else
        @item_masters = ItemMaster.all 
        @item_articles = ItemMaster.pluck(:article_number).compact.uniq
        render :new
      end
    end
    def index
      dispatched_order_entry_ids = DispatchItem
                                     .joins(:dispatch)
                                     .where(dispatches: { progress: 'Dispatched' })
                                     .pluck(:order_entry_id)
                                     .uniq
    

                                     @q = OrderEntry
                                     .includes(:client)
                                     .left_joins(dispatch_items: :dispatch)
                                     .where.not(id: dispatched_order_entry_ids)
                                     .select('order_entries.*, MIN(dispatches.d_id) AS dispatch_d_id') 
                                     .group('order_entries.id') 
                                     .ransack(params[:q].presence || {})
                                   
    
      @order_entries = @q.result
                         .paginate(page: params[:page], per_page: 100)
    
      color_classes = %w[bg-red-100 bg-green-100 bg-blue-100 bg-yellow-100 bg-purple-100 bg-pink-100]
      @dispatch_color_map = {}
      color_index = 0
    
      @order_entries.each do |order|
        dispatch_no = order.dispatch_no&.strip
        next unless dispatch_no.present?

    
        unless @dispatch_color_map[dispatch_no]
          @dispatch_color_map[dispatch_no] = color_classes[color_index % color_classes.length]
          color_index += 1
        end
      end
    end
    
    
  
    def show
      @order_entry = OrderEntry.find(params[:id])
    end
    def update
      @order_entry = OrderEntry.find(params[:id])
      if @order_entry.update(order_entry_params_upload)
        redirect_to order_entries_path, notice: "Order updated successfully."
      else
        render :show
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
        :driver_revision_no,
        :invoice_no,
        :tracking_no,
        :dispatch_no,
        :status,
        :box,
        :extra
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
  