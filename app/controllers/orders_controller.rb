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
        wiring_map: decoded[:wiring]
      }
    end
  end
end
