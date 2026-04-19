class SerialNumbersController < ApplicationController
  skip_before_action :authenticate_user!, raise: false

  def show
    if params[:id].present? || params[:q].present?
      @sno_input = (params[:id] || params[:q]).to_s.strip
      base_sno = @sno_input.split('_').first
      
      if base_sno.present? && base_sno.match?(/^\d+$/)
        sno_int = base_sno.to_i
        
        # We can just fetch all valid ranges and check
        orders = OrderEntry.where.not(start_serial_no: [nil, '']).where.not(end_serial_no: [nil, ''])
        @order_entry = orders.find do |order|
          start_int = order.start_serial_no.gsub(/\D/, '').to_i
          end_int = order.end_serial_no.gsub(/\D/, '').to_i
          start_int > 0 && end_int >= start_int && sno_int >= start_int && sno_int <= end_int
        end
        
        if @order_entry.present?
          suffix = @sno_input.split('_', 2)[1]
          
          if suffix.present?
            fg = FinishedGood.find_by(sku_id: @order_entry.sku_number)
            bom = fg&.bill_of_material
            bom_items = bom ? bom.bom_raw_material_items.includes(:item_master) : []
            sub_boms = bom_items.select { |item| item.item_master&.is_bom? }
            
            valid_bom_strs = sub_boms.map.with_index do |sub_bom, index|
              (sub_bom.item_master.bill_of_material&.bom_number&.gsub(/[^0-9]/, '')&.to_i || (index + 1)).to_s
            end
            
            if valid_bom_strs.include?(suffix)
              @sno_found = true
            else
              @sno_found = false
            end
          else
            @sno_found = true
          end
        else
          @sno_found = false
        end
      end
    end
    
    render layout: 'public_minimal'
  end
end
