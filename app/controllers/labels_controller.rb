class LabelsController < ApplicationController
  def index
    @item_masters = ItemMaster.all
  end

  def generate_pdf
    @sticker= OrderEntry.find(params[:order_id])
    @form_data = params.to_unsafe_h.except(:authenticity_token, :commit, :controller, :action, :format)
    @client = Client.find_by(id: @form_data[:manufacturer_id])
    @distributor = Client.find_by(id: @form_data[:distributor_id]) 

    I18n.locale = @form_data["language"].presence || :en  
    Rails.logger.info "🧾 PDF PARAMS => #{@form_data.inspect}"
  
    respond_to do |format|
      format.pdf do
        render pdf: "#{@sticker.order_no}",
               template: "labels/label_pdf",
               orientation: 'Landscape',
               layout: "pdf",
               formats: [:html],
               page_size: 'A4',
               encoding: "UTF-8",
               show_as_html: params.key?("debug")
      end
    end
  end
  
  def get_item_details
    @item_master = ItemMaster.find(params[:item_master_id])
    render json: {
      sku_id: @item_master.sku_id,
      item_name: @item_master.item_name,
      category: @item_master.category&.name,
      measurement: @item_master.measurement&.name,
      opening_stock: @item_master.opening_stock,
      article_number: @item_master.article_number,
      length: @item_master.length&.name,
      voltage: @item_master.voltage&.name,
      cct: @item_master.cct&.name
    }
  end

  def new_product_label
    @label_type = "product"
    @item_masters = ItemMaster.all
  
    if params[:order_id].present?
      order = OrderEntry.find(params[:order_id])
      @order_details = {
        order_id: order.id,
        article_no: order.article_no,
        sku_number: order.sku_number,
        wattage: order.wattage,
        qty: order.qty,
        type: order.item_type,
        length: order.length,
        voltage: order.voltage,
        cct: order.cct,
        profile: order.profile,
        cover: order.cover_type,
        extra: order.extra
      }
    else
      @order_details = {}
    end
  
    render :label_form
  end
  
end
