# app/controllers/raw_material_inwards_controller.rb

class RawMaterialInwardsController < ApplicationController
    def new
      @raw_material_inward = RawMaterialInward.new
    end
  
    def index
        @raw_material_inwards = RawMaterialInward.all.order(created_at: :desc)
    end

    def create
      @raw_material_inward = RawMaterialInward.new(raw_material_inward_params)
      if @raw_material_inward.save
        redirect_to raw_material_inwards_path, notice: 'Raw material inward successfully created.'
      else
        render :new
      end
    end
  
    def show
      @raw_material_inward = RawMaterialInward.find(params[:id])
    end
  
    private
  
    def raw_material_inward_params
      params.require(:raw_material_inward).permit(
        :supplier_name,
        :receiving_date,
        :sku_id,
        :item_name,
        :receiving_quantity,
        :purchase_price
      )
    end
  end
  