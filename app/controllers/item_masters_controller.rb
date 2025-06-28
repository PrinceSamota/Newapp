class ItemMastersController < ApplicationController
    def show
        @item_master = ItemMaster.find(params[:id])
      end
      
      def create
        @item_master = ItemMaster.new(item_master_params)
        @item_master.org_id = current_user.org_id 
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
      def check_bom_usage
        item = ItemMaster.find_by(sku_id: params[:sku_id])
        boms = BillOfMaterial.joins(:bom_raw_material_items)
                             .where(bom_raw_material_items: { sku_id: item.sku_id })
    
        render json: {
          used: boms.exists?,
          bom_names: boms.pluck(:bom_number, :name)
        }
      end
    private
  
    def item_master_params
      params.require(:item_master).permit(
        :item_name, :opening_stock,
        :purchase_price, :sale_price, :is_bOM, :minimum_stock_level, :category_id, :measurement_id, :org_id
      )
    end
  end
  