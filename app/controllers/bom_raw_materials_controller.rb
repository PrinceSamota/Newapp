  class BomRawMaterialsController < ApplicationController
    def create
        @raw_material = BomRawMaterial.new(raw_material_params)
        if @raw_material.save
          @bom = @raw_material.bom
          respond_to do |format|
            format.turbo_stream
            format.html { redirect_to new_bom_path }
          end
        else
          render plain: "Error saving raw material", status: :unprocessable_entity
        end
      end
    
      private
    
      def raw_material_params
        params.permit(:bom_id, :raw_material_sku, :quantity)
      end
    end