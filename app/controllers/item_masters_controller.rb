class ItemMastersController < ApplicationController
    def show
        @item_master = ItemMaster.find(params[:id])
      end

      def versions
        @item_master = ItemMaster.find(params[:id])
        @versions = @item_master.versions.order(created_at: :desc)
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
      def edit
        @item_master = ItemMaster.find(params[:id])
      end
      
      def update
        @item_master = ItemMaster.find(params[:id])
        if @item_master.update(item_master_params)
          redirect_to root_path, notice: "Item updated successfully!"
        else
          render :edit
        end
      end
      
      def decode_article
        article_number = params[:article_number]
      
        decoded = ArticleDecoder.new(article_number).decode
      
        render json: decoded
      end
      def check_bom_usage
        item = ItemMaster.find_by(sku_id: params[:sku_id])
        boms = BillOfMaterial.joins(:finished_good)
                             .where(finished_good: { sku_id: item.sku_id })
    
        render json: {
          used: boms.exists?,
          bom_names: boms.pluck(:bom_number, :name)
        }
      end
      def fetch_by_article
        item = ItemMaster.find_by(article_number: params[:article_number])
      
        if item
          render json: {
            fuse_type: item.fuse_type&.name,
            loop: item.loop&.name,
            item_type: item.item_type&.name,
            profile: item.profile&.name,
            wattage: item.wattage&.name,
            voltage: item.voltage&.name,
            length: item.length&.name,
            cct: item.cct&.name,
            cover_type: item.cover_type&.name,
            sku_id: item.sku_id
          }
        else
          render json: { error: "Item not found" }, status: :not_found
        end
      end

      
    private
  
    def item_master_params
      params.require(:item_master).permit(
        :item_name,
        :opening_stock,
        :purchase_price,
        :sale_price,
        :is_bOM,
        :minimum_stock_level,
        :category_id,
        :measurement_id,
        :org_id,
        :fuse_type_id,
        :cct_id,
        :cover_type_id,
        :item_type_id,
        :length_id,
        :loop_id,
        :profile_id,
        :voltage_id,
        :wattage_id,
        :extra_id,
        :article_number
      )
    end
  end
  