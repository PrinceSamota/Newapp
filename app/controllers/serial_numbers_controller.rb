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
        
        @sno_found = @order_entry.present?
      end
    end
    
    render layout: 'public_minimal'
  end
end
