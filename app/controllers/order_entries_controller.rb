class OrderEntriesController < ApplicationController
    def new
        @order_entry = OrderEntry.new
        @item_masters = ItemMaster.all
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
        render :new
      end
    end
    def index
      @order_entries = OrderEntry.all
    end
  
    def show
      @order_entry = OrderEntry.find(params[:id])
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
        :fuse_type,
        :loop,
        :ptype,
        :profile,
        :voltage,
        :wattage,
        :length,
        :cct,
        :cover_type,
        :sku_number
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
  