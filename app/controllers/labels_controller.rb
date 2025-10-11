class LabelsController < ApplicationController
  def index
    @item_masters = ItemMaster.all
  end

  def generate_pdf
    @form_data = params.except(:authenticity_token, :commit)
    
    respond_to do |format|
      format.pdf do
        render pdf: "label_#{@form_data[:custom_article_no] || @form_data[:article_number] || Time.current.to_i}",
               template: "labels/label_pdf",
               layout: "pdf",
               formats: [:html],
               page_size: 'A4',
               encoding: "UTF-8",
               show_as_html: params.key?('debug')
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
      voltage: @item_master.voltage&.name
    }
  end

  def new_product_label
    @label_type = "product"
    @item_masters = ItemMaster.all
    
    # Order details from params
    @order_details = {
      order_id: params[:order_id],
      article_no: params[:article_no],
      sku_number: params[:sku_number],
      qty: params[:qty]
    }
    
    render :label_form
  end
end
