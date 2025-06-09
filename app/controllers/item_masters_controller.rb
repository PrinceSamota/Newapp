class ItemMastersController < ApplicationController
    def show
        @item_master = ItemMaster.find(params[:id])
      end
      
      def create
        @item_master = ItemMaster.new(item_master_params)
      
        respond_to do |format|
          if @item_master.save
            format.html { redirect_to root_path, notice: "Item Master successfully created." }
            format.js   # Looks for create.js.erb
          else
            format.html { redirect_to uploads_path, alert: "Failed to create Item Master." }
            format.js   # Handles failure via JS
          end
        end
      end
      
      def decode_article
        article_number = params[:article_number]
      
        decoded = ArticleDecoder.new(article_number).decode
      
        render json: decoded
      end
    private
  
    def item_master_params
      params.require(:item_master).permit(
        :item_name, :unit_of_measurement, :item_category, :opening_stock,
        :purchase_price, :sale_price, :minimum_stock_level, :is_bOM,
        :article_no, :loop_color, :client, :status, :profile, :start_serial_no,
        :end_serial_no, :invoice_no, :fuse, :tracking_no,
        :current_status, :manufacturing_date, :dispatch_date, :delivery_date
      )
    end
  end
  