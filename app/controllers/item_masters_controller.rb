class ItemMastersController < ApplicationController
  before_action :set_paper_trail_whodunnit
    def index
      @decoded_result = nil
      @article_number = nil
      @q = ItemMaster.ransack(params[:q])
      @item_masters = @q.result(distinct: true).order(created_at: :desc).paginate(page: params[:page], per_page: 100)
      @selected_fuse_type_id = nil
      @show_fuse_form = false
      @fuse_type_errors = []

      respond_to do |format|
        format.html
        format.csv do 
          send_data ItemMaster.to_csv,
          filename: "item_masters_#{Date.today}.csv"
        end
      end
    end
    
    def show
        @item_master = ItemMaster.find(params[:id])
      end

      def versions
        @item_master = ItemMaster.find(params[:id])
        @versions = @item_master.versions.reorder(created_at: :desc)
      end
      
      def create
        @item_master = ItemMaster.new(item_master_params)
        @item_master.org_id = current_user.org_id
      
        respond_to do |format|
          if @item_master.save
            format.html { redirect_to item_masters_path, notice: "Item Master successfully created." }
            format.js
          else
            format.html { render :new, status: :unprocessable_entity }
            format.js
          end
        end
      end
      
      def new
        if params[:clone_id].present?
          original_item = ItemMaster.find_by(id: params[:clone_id])
      
          if original_item
            @item_master = original_item.dup
            if original_item.is_bom
              @item_master.item_name = nil
            end 
          else
            @item_master = ItemMaster.new
          end
        else
          @item_master = ItemMaster.new
          @item_master.is_bom = false
        end
      end
      def edit
        @item_master = ItemMaster.find(params[:id])
      end
      
      def update
        @item_master = ItemMaster.find(params[:id])
      
        new_params = item_master_params
      
        was_bom = @item_master.is_bom
        will_be_bom = ActiveModel::Type::Boolean.new.cast(new_params[:is_bom])
      
        if was_bom && !will_be_bom
          new_params = new_params.merge(
            fuse_type_id: nil,
            loop_id: nil,
            item_type_id: nil,
            profile_id: nil,
            wattage_id: nil,
            voltage_id: nil,
            length_id: nil,
            cct_id: nil,
            cover_type_id: nil,
            article_number: nil,
            extra_id: nil
          )
        end
      
        if @item_master.update(new_params)
          redirect_to root_path, notice: "Item Master updated successfully."
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
      
        if item.nil?
          render json: { used: false, bom_names: [], bom_ids: [] } and return
        end
      
        boms = BillOfMaterial.joins(:finished_good)
                             .where(finished_good: { sku_id: item.sku_id })
      
        render json: {
          used: boms.exists?,
          bom_names: boms.map { |bom| "#{bom.bom_number}" },
          bom_ids: boms.pluck(:id)
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
      def fetch_by_sku
        item = ItemMaster.find_by(sku_id: params[:sku_id])
      
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
            extra: item.extra&.name,
            article_number: item.article_number
          }
        else
          render json: { error: "Not found" }, status: :not_found
        end
      end
      
      def update_stock
        @item_master = ItemMaster.find(params[:id])
        stock_value = params[:stock_value].to_f
        operation = params[:operation]
        comment = params[:comment]
        PaperTrail.request.whodunnit = current_user.id
        PaperTrail.request.controller_info = { reason: params[:comment] }
        if operation == "add"
          @item_master.opening_stock += stock_value
        elsif operation == "subtract"
          @item_master.opening_stock -= stock_value
        end
      
        if @item_master.save
          redirect_to versions_item_master_path(@item_master), notice: "Stock updated successfully"
        else
          redirect_to versions_item_master_path(@item_master), alert: "Failed to update stock"
        end
      end
      
      def update_block_stock
        @item_master = ItemMaster.find(params[:id])
        quantity = params[:block_value].to_i
        operation = params[:operation]
        user_comment = params[:comment].to_s.strip
      
        formatted_reason =
          if operation == "block"
            "Block (#{user_comment})"
          elsif operation == "unblock"
            "Unblock (#{user_comment})"
          else
            user_comment
          end
      
        PaperTrail.request.whodunnit = current_user.id
        PaperTrail.request.controller_info = { reason: formatted_reason }
      
        case operation
        when "block"
          if quantity > @item_master.opening_stock
            redirect_to versions_item_master_path(@item_master), alert: "Not enough stock to block! Available: #{@item_master.opening_stock}" and return
          end
      
          @item_master.opening_stock -= quantity
          @item_master.block_stock = (@item_master.block_stock || 0) + quantity
          notice_msg = "Blocked #{quantity} stocks successfully. (Reason: #{user_comment})"
      
        when "unblock"
          if quantity > @item_master.block_stock.to_i
            redirect_to versions_item_master_path(@item_master), alert: "Not enough blocked stock to unblock! Currently blocked: #{@item_master.block_stock.to_i}" and return
          end
      
          @item_master.block_stock -= quantity
          @item_master.opening_stock += quantity
          notice_msg = "Unblocked #{quantity} stocks successfully. (Reason: #{user_comment})"
        end
      
        if @item_master.save
          @item_master.reload
          @item_master.versions.reload
      
          redirect_to versions_item_master_path(@item_master), notice: notice_msg
        else
          redirect_to versions_item_master_path(@item_master), alert: "Failed to update block stock."
        end
      end

      
    private
  
    def item_master_params
      params.require(:item_master).permit(
        :item_name,
        :opening_stock,
        :purchase_price,
        :sale_price,
        :is_bom,
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
        :article_number,
        :shortcode
      )
    end
  end
  