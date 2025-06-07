class OrdersController < ApplicationController
  def show
    @order = Order.find(params[:id])
    @items = @order.items
  
    @decoded_items = @items.map do |item|
      decoded = ArticleDecoder.new(item.article_no).decode

      if decoded.nil?
        decoded = {
          service: "Unknown",
          type: "-",
          suspension: "-",
          voltage: "-",
          length: "-",
          kelvin: "-",
          cover: "-",
          watt: "-"
        }
      end
  
      {
        sheet_name: @order.name,
        article_no: item.article_no,
        service: decoded[:service],
        type: decoded[:type],
        suspension: decoded[:suspension],
        voltage: decoded[:voltage],
        length: decoded[:length],
        kelvin: decoded[:kelvin],
        cover: decoded[:cover],
        watt: decoded[:watt],
        stripe_set: decoded[:stripe_set],
        profile: decoded[:profile],
        output_count: decoded[:output_count],
        output_voltage: decoded[:output_voltage],
        outputs_count: decoded[:outputs],
        wiring_map: decoded[:wiring],
        loop_color: item.loop_color,
        client: item.client,
        status: item.status,
        profile2: item.profile,
        start_serial_no: item.start_serial_no,
        end_serial_no: item.end_serial_no,
        invoice_no: item.invoice_no,
        fuse: item.fuse,
        sku_no: item.sku_no,
      }
    end
    @decoded_items.each do |decoded|
      @order.order_details.create(
        sheet_name: decoded[:sheet_name],
        article_no: decoded[:article_no],
        service: decoded[:service],
        fixture_type: decoded[:type], 
        suspension: decoded[:suspension],
        voltage: decoded[:voltage],
        length: decoded[:length],
        kelvin: decoded[:kelvin],
        cover: decoded[:cover],
        watt: decoded[:watt],
        stripe_set: decoded[:stripe_set],
        profile: decoded[:profile],
        output_count: decoded[:output_count],
        output_voltage: decoded[:output_voltage],
        outputs_count: decoded[:outputs_count],
        wiring_map: decoded[:wiring_map],
        loop_color: decoded[:loop_color],
        client: decoded[:client],
        status: decoded[:status],
        profile2: decoded[:profile2],
        start_serial_no: decoded[:start_serial_no],
        end_serial_no: decoded[:end_serial_no],
        invoice_no: decoded[:invoice_no],
        fuse: decoded[:fuse],
        sku_no: decoded[:sku_no]
      )
    end
  end
end
