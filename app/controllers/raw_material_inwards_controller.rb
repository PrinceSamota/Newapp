# app/controllers/raw_material_inwards_controller.rb

class RawMaterialInwardsController < ApplicationController
  def new
    @raw_material_inward = RawMaterialInward.new
    @raw_material_inwards = RawMaterialInward.all.order(created_at: :desc)
  end
  
  def create
    @raw_material_inward = RawMaterialInward.new(raw_material_inward_params)
    if @raw_material_inward.save
      redirect_to new_raw_material_inward_path, notice: "Raw material inward created successfully."
    else
      @raw_material_inwards = RawMaterialInward.all.order(created_at: :desc)
      render :new, status: :unprocessable_entity
    end
  end
  
  private
  
  def raw_material_inward_params
    params.require(:raw_material_inward).permit(:supplier_name, :receiving_date, :sku_id, :item_name, :receiving_quantity, :purchase_price)
  end
  
  end
  