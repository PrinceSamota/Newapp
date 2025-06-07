class BomsController < ApplicationController
  def index
    @bom = Bom.new
    @item_masters = ItemMaster.all
    @boms = Bom.order(created_at: :desc) 

  end

  def new
    @bom = Bom.new
    @item_masters = ItemMaster.where(is_bOM: true)
    @boms = Bom.order(created_at: :desc) 
  end

  def create
    @bom = Bom.new(bom_params)
    if @bom.save
      @boms = Bom.order(created_at: :desc)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to new_bom_path, notice: "BOM created successfully." }
      end
    else
      @item_masters = ItemMaster.all
      @boms = Bom.order(created_at: :desc)
      render :new, status: :unprocessable_entity
    end
  end

  private

  def bom_params
    params.require(:bom).permit(:item_master_id, :finished_good, :quantity, :unit)
  end
end
