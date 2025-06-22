class BillOfMaterialsController < ApplicationController
  def new
    @bill_of_material = BillOfMaterial.new
    @bill_of_material.build_finished_good
    @bill_of_material.bom_raw_material_items.build
    @item_masters = ItemMaster.where(is_bom: true) # Only BOM items
  end

  def create
    @bill_of_material = BillOfMaterial.new(bom_params)
    if @bill_of_material.save
      redirect_to bill_of_materials_path, notice: "BOM created successfully"
    else
      @item_masters = ItemMaster.where(is_bom: true)
      render :new, status: :unprocessable_entity
    end
  end
  def index
    @bill_of_materials = BillOfMaterial.includes(:finished_good, :bom_raw_material_items).order(created_at: :desc)
  end

  private

  def bom_params
    params.require(:bill_of_material).permit(
    :name,
    finished_good_attributes: [:sku_id, :item_name, :quantity, :unit],
    bom_raw_material_items_attributes: [:sku_id, :item_name, :quantity, :unit, :_destroy]
  )
  end
end
