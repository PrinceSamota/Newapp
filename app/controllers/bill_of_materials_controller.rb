class BillOfMaterialsController < ApplicationController
  
  def new
    @bill_of_material = BillOfMaterial.new
    @bill_of_material.build_finished_good
    @bill_of_material.bom_raw_material_items.build
    @item_masters = ItemMaster.where('"item_masters"."is_bom" = ?', true).includes(:measurement) 
    @item_masters_false = ItemMaster.where('"item_masters"."is_bom" = ?', false).includes(:measurement)
    @item_masters_all = ItemMaster.all
    used_finished_good_skus = FinishedGood.pluck(:sku_id)
    @item_masters_good = ItemMaster
    .where('"item_masters"."is_bom" = ?', true)
    .where.not(sku_id: used_finished_good_skus)
    .includes(:measurement)

  end

  def create
    @bill_of_material = BillOfMaterial.new(bom_params)
    @item_masters = ItemMaster.where('"item_masters"."is_bom" = ?', true).includes(:measurement) 
    @item_masters_false = ItemMaster.where('"item_masters"."is_bom" = ?', false).includes(:measurement) 
    @item_masters_all = ItemMaster.all
    if @bill_of_material.save!
      redirect_to bill_of_materials_path, notice: "BOM created successfully"
    else
      @item_masters = ItemMaster.where('"item_masters"."is_bom" = ?', true).includes(:measurement) 
      @item_masters_false = ItemMaster.where('"item_masters"."is_bom" = ?', false).includes(:measurement) 
      @item_masters_all = ItemMaster.all
      render :new, status: :unprocessable_entity
    end

    
  end

  def update_stock
    @po = ProductionOrder.find(params[:id])
    
    production_order_item = @po.production_order_items.last if @po.production_order_items

    
    if production_order_item.nil?
      redirect_to production_orders_path, alert: "Production Order Item not found."
      return
    end
    @bom = BillOfMaterial.find_by_bom_number(production_order_item.bom)

    multiplier = production_order_item.quantity.to_f
  
    PaperTrail.request(controller_info: {
      source_type: "BillOfMaterial",
      source_id: @bom.id
    }) do
      if (fg = @bom.finished_good).present?
        fg_item = ItemMaster.find_by(sku_id: fg.sku_id)
        if fg_item
          new_stock = fg_item.opening_stock.to_f + (fg.quantity.to_f * multiplier)
          fg_item.update(opening_stock: new_stock)
        end
      end
  
      @bom.bom_raw_material_items.each do |rm|
        rm_item = ItemMaster.find_by(sku_id: rm.sku_id)
        if rm_item
          new_stock = rm_item.opening_stock.to_f - (rm.quantity.to_f * multiplier)
          rm_item.update(opening_stock: new_stock)
        end
      end
    end
    @po.update(executed: true)
    redirect_to production_orders_path, notice: "Stock updated successfully for BOM ##{@bom.bom_number}."
  end

  def index
    @q = BillOfMaterial.includes(:finished_good, :bom_raw_material_items).order("created_at DESC").ransack(params[:q])
    @bill_of_materials = @q.result(distinct: true).paginate(page: params[:page], per_page: 100)

    respond_to do |format|
      format.html
      format.csv do 
        send_data BillOfMaterial.to_csv,
        filename: "bill_of_materials_#{Date.today}.csv"
      end
    end
  end
  
  def show
    @bill_of_material = BillOfMaterial.find(params[:id])
    @item_masters = ItemMaster.where('"item_masters"."is_bom" = ?', true).includes(:measurement) 
    @item_masters_false = ItemMaster.where('"item_masters"."is_bom" = ?', false).includes(:measurement)
    @item_masters_all = ItemMaster.all
  end
  def clone
    original_bom = BillOfMaterial.find(params[:id])
    @bill_of_material = original_bom.dup
    @bill_of_material.finished_good = original_bom.finished_good.dup if original_bom.finished_good.present?
    @bill_of_material.bom_raw_material_items = original_bom.bom_raw_material_items.map(&:dup)
    
    @item_masters = ItemMaster.where('"item_masters"."is_bom" = ?', true).includes(:measurement)  
    @item_masters_false = ItemMaster.where('"item_masters"."is_bom" = ?', false).includes(:measurement) 
    @item_masters_all = ItemMaster.all
    used_finished_good_skus = FinishedGood.pluck(:sku_id)
    @item_masters_good = ItemMaster
    .where('"item_masters"."is_bom" = ?', true)
    .where.not(sku_id: used_finished_good_skus)
    .includes(:measurement)

    render :new
  end
  def update_bom_all_items
    @bill_of_material = BillOfMaterial.find(params[:id])
  
    if @bill_of_material.update(bom_params_update)
      redirect_to bill_of_materials_path, notice: "Updated successfully"
    else
      @item_masters = ItemMaster.where('"item_masters"."is_bom" = ?', true).includes(:measurement)
      @item_masters_false = ItemMaster.where('"item_masters"."is_bom" = ?', false).includes(:measurement)
      @item_masters_all = ItemMaster.all
  
      used_finished_good_skus = FinishedGood.pluck(:sku_id)
      @item_masters_good = ItemMaster
        .where('"item_masters"."is_bom" = ?', true)
        .where.not(sku_id: used_finished_good_skus)
        .includes(:measurement)
  
      render :show, status: :unprocessable_entity
    end
  end
  
  
  def find_by_sku
    sku_id = params[:sku_id]
    item_name = params[:item_name]
    
    bom = BillOfMaterial
    .includes(:bom_raw_material_items)
    .joins(:finished_good)
    .find_by(finished_goods: { sku_id: sku_id, item_name: item_name })
    
    if bom
      render json: {
        bom_name: bom.name,
        finished_good: bom.finished_good,
        raw_materials: bom.bom_raw_material_items.map { |rm| {
          item_name: rm.item_name,
          sku_id: rm.sku_id,
          quantity: rm.quantity,
          unit: rm.unit
        } }
      }
    else
      render json: { error: "No BOM found" }, status: :not_found
    end
  end
  def bom_details
    sku_id = params[:sku_id]
    item_name = params[:item_name]

    @bom = BillOfMaterial
    .joins(:finished_good)
    .includes(:bom_raw_material_items)
    .find_by(finished_goods: { sku_id: sku_id, item_name: item_name })

    if @bom.nil?
      redirect_to production_orders_path, alert: "No BOM found for this Finished Good"
    else
        render 'production_orders/bom_details'
      end
    end
    
    private

    def bom_params
      params.require(:bill_of_material).permit(
        :name, :bom_tag,
        finished_good_attributes: [:sku_id, :item_name, :quantity, :item_master_id, :unit],
        bom_raw_material_items_attributes: [:sku_id, :item_name, :quantity, :unit, :item_master_id, :_destroy]
        )
    end
    def bom_params_update
      params.require(:bill_of_material).permit(
        :name, :bom_tag,
        finished_good_attributes: [:id, :sku_id, :item_name, :quantity, :item_master_id, :unit, :_destroy],
        bom_raw_material_items_attributes: [:id, :sku_id, :item_name, :item_master_id, :item_master_id, :quantity, :unit, :_destroy]
        )
    end
  end
