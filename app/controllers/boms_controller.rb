class BomsController < ApplicationController
  def index
    @bom = Bom.new
    @item_masters = ItemMaster.all
    @boms = Bom.order(created_at: :desc) 

  end

  def new
    @bom = Bom.new
    @item_masters = ItemMaster.where(is_bom: true)
    @boms = Bom.order(created_at: :desc) 
    
  end

  def create
    @bom = Bom.new(bom_params)
    @bom.org_id = current_user.org_id
    @bom.sku_id = ItemMaster.find(@bom.item_master_id).sku_id
    if @bom.save
      redirect_to new_bom_path, notice: "BOM created successfully."
    else
      @item_masters = ItemMaster.where(is_bom: true)
      @boms = Bom.order(created_at: :desc)
      render :new, status: :unprocessable_entity
    end
  end

  private

  def bom_params
    params.require(:bom).permit(:item_master_id, :sku_id, :quantity, :unit)
  end
end
