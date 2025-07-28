class OrderEntriesController < ApplicationController
  require 'ostruct'
    def new
        @order_entry = OrderEntry.new
        @item_masters = ItemMaster.all
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
                               .where(dispatches: { progress: 'Shipment' })
                               .pluck(:order_no)
    
                               @order_entries = OrderEntry
                        .includes(:client, :status)
                        .where.not(order_no: dispatched_order_nos)
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
        :ship_to_location,
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
        :status_id,
        :remark,
        :generate_serial
      )
    end
    def order_entry_params_upload
      params.require(:order_entry).permit(
        :order_no,
        :article_no,
        :client_id,
        :target_date,
        :ship_to_location,
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
        :status_id
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
  