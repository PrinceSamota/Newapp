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
      dispatched_order_nos = DispatchItem
                               .joins(:dispatch)
                               .where(dispatches: { progress: 'Dispatched' })
                               .pluck(:order_no)
    
                               @q = OrderEntry
                               .includes(:client)
                               .where.not(order_no: dispatched_order_nos).ransack(params[:q])
                                @order_entries = @q.result(distinct: true).paginate(page: params[:page], per_page: 30)
                               
                               color_classes = %w[bg-red-100 bg-green-100 bg-blue-100 bg-yellow-100 bg-purple-100 bg-pink-100]
                               @dispatch_color_map = {}
                               color_index = 0
                             
                               @order_entries.each do |order|
                                 d_id = order.dispatch_d_id
                                 next unless d_id.present?
                             
                                 unless @dispatch_color_map[d_id]
                                   @dispatch_color_map[d_id] = color_classes[color_index % color_classes.length]
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
  