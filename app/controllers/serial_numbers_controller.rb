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
        matching_orders = orders.select do |order|
          start_int = order.start_serial_no.gsub(/\D/, '').to_i
          end_int = order.end_serial_no.gsub(/\D/, '').to_i
          start_int > 0 && end_int >= start_int && sno_int >= start_int && sno_int <= end_int
        end
        
        @order_entry = matching_orders.find { |order| order.qr_links_map&.[](@sno_input).present? }
        @order_entry ||= matching_orders.min_by do |order|
          start_int = order.start_serial_no.gsub(/\D/, '').to_i
          end_int = order.end_serial_no.gsub(/\D/, '').to_i
          end_int - start_int
        end
        
        if @order_entry.present?
          suffix = @sno_input.split('_', 2)[1]
          
          if suffix.present?
            fg = FinishedGood.find_by(sku_id: @order_entry.sku_number)
            bom = fg&.bill_of_material
            bom_items = bom ? bom.bom_raw_material_items.includes(:item_master) : []
            sub_boms = bom_items.select { |item| item.item_master&.is_bom? }
            
            # Replicate the exact unit_counter sequence to find which sub_bom matches the suffix
            matched_sub_bom = nil
            unit_counter = 1
            sub_boms.each do |sub_bom|
              qty = sub_bom.quantity.to_i
              qty.times do
                if unit_counter.to_s == suffix
                  matched_sub_bom = sub_bom
                  break
                end
                unit_counter += 1
              end
              break if matched_sub_bom
            end
            
            if matched_sub_bom.present?
              @sno_found = true
              original_item_master = matched_sub_bom.item_master
              
              if original_item_master.present?
                overridden_article = @order_entry.qr_links_map&.[](@sno_input) || @order_entry.qr_links_map&.[](original_item_master.id.to_s)
                article_to_decode = overridden_article.presence || original_item_master.article_number
                
                if article_to_decode.present?
                  db_item_master = ItemMaster.find_by(article_number: article_to_decode)
                  if db_item_master.present?
                    @component_item_master = db_item_master
                  else
                    @component_item_master = ItemMaster.new(original_item_master.attributes)
                    @component_item_master.article_number = article_to_decode
                    
                    decoded = ArticleDecoder.new(article_to_decode).decode
                    @component_item_master.item_type = ItemType.find_or_create_by(name: decoded[:type]) if decoded[:type].present?
                    @component_item_master.voltage = Voltage.find_or_create_by(name: decoded[:voltage]) if decoded[:voltage].present?
                    @component_item_master.length = Length.find_or_create_by(name: decoded[:length]) if decoded[:length].present?
                    @component_item_master.cct = Cct.find_or_create_by(name: decoded[:kelvin]) if decoded[:kelvin].present?
                    @component_item_master.cover_type = CoverType.find_or_create_by(name: decoded[:cover]) if decoded[:cover].present?
                    @component_item_master.wattage = Wattage.find_or_create_by(name: decoded[:watt]) if decoded[:watt].present?
                    @component_item_master.profile = Profile.find_or_create_by(name: decoded[:profile]) if decoded[:profile].present?
                  end
                else
                  @component_item_master = original_item_master
                end
              else
                @component_item_master = nil
              end
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

    if @order_entry.present? && @sno_found
      if @component_item_master.present?
        @display_article_no = @component_item_master.article_number
        @display_item_type = @component_item_master.item_type&.name
        @display_length = @component_item_master.length&.name
        @display_profile = @component_item_master.profile&.name
        @display_cct = @component_item_master.cct&.name
        @display_cover_type = @component_item_master.cover_type&.name
        @display_voltage = @component_item_master.voltage&.name
        @display_wattage = @component_item_master.wattage&.name
        @display_fuse_type = @component_item_master.fuse_type&.name
      else
        @display_article_no = @order_entry.article_no
        @display_item_type = @order_entry.item_type
        @display_length = @order_entry.length
        @display_profile = @order_entry.profile
        @display_cct = @order_entry.cct
        @display_cover_type = @order_entry.cover_type
        @display_voltage = @order_entry.voltage
        @display_wattage = @order_entry.wattage
        @display_fuse_type = @order_entry.fuse_type
      end
      @display_mfg_date = @order_entry.mfg_date
      @display_driver_revision = @order_entry.driver_revision&.name
    end
    
    render layout: 'public_minimal'
  end
end
