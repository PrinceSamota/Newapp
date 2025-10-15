class DocumentsController < ApplicationController
  def index
    # Main page with 6 document types
  end

  def invoice
    @document_type = "invoice"
    @dispatches = Dispatch.all
  end

  def packing_list
    @document_type = "packing_list"
    @dispatches = Dispatch.all
  end

  def new_si
    @document_type = "new_si"
    @dispatches = Dispatch.all
  end

  def value_letter
    @document_type = "value_letter"
    @dispatches = Dispatch.all
  end

  def sheet_5
    @document_type = "sheet_5"
    @dispatches = Dispatch.all
  end

  def scomet
    @document_type = "scomet"
    @dispatches = Dispatch.all
  end

  def generate_pdf
    if params[:input_id].present?
      @input = Input.find(params[:input_id])
    elsif params[:document_type] == "invoice" || params[:document_type] == "packing_list" || params[:document_type] == "value_letter" || params[:document_type] == "scomet" || params[:document_type] == "sheet_5" || params[:document_type] == "new_si"
      @dispatch = Dispatch.find(params[:dispatch_id])
    else
      @order_entry = OrderEntry.find(params[:order_entry_id])
    end
    
    @document_type = params[:document_type]
    @form_data = params.except(:dispatch_id, :order_entry_id, :input_id, :document_type, :authenticity_token, :commit)

    if @document_type == "invoice"
      if @input&.shipper_name&.logo&.attached?
        logo_file = @input.shipper_name.logo.download
        @logo_data = Base64.strict_encode64(logo_file)
      end

      if @input&.shipper_name&.signature&.attached?
        signature_file = @input.shipper_name.signature.download
        @signature_data = Base64.strict_encode64(signature_file)
      end
    end


    if @document_type == "packing_list"
      if @input&.shipper_name&.logo&.attached?
        logo_file = @input.shipper_name.logo.download
        @logo_data = Base64.strict_encode64(logo_file)
      end
    
      if @input&.shipper_name&.signature&.attached?
        signature_file = @input.shipper_name.signature.download
        @signature_data = Base64.strict_encode64(signature_file)
      end
    end

    if @document_type == "value_letter"
      if @input&.shipper_name&.logo&.attached?
        logo_file = @input.shipper_name.logo.download
        @logo_data = Base64.strict_encode64(logo_file)
      end
    
      if @input&.shipper_name&.signature&.attached?
        signature_file = @input.shipper_name.signature.download
        @signature_data = Base64.strict_encode64(signature_file)
      end
    end

    if @document_type == "sheet_5"
      if @input&.shipper_name&.logo&.attached?
        logo_file = @input.shipper_name.logo.download
        @logo_data = Base64.strict_encode64(logo_file)
      end
    
      if @input&.shipper_name&.signature&.attached?
        signature_file = @input.shipper_name.signature.download
        @signature_data = Base64.strict_encode64(signature_file)
      end
    end
    if @document_type == "scomet"
      if @input&.shipper_name&.logo&.attached?
        logo_file = @input.shipper_name.logo.download
        @logo_data = Base64.strict_encode64(logo_file)
      end
    
      if @input&.shipper_name&.signature&.attached?
        signature_file = @input.shipper_name.signature.download
        @signature_data = Base64.strict_encode64(signature_file)
      end
    end

    respond_to do |format|
      format.pdf do
        template_name = case @document_type
                       when "invoice"
                         "documents/invoice_pdf"
                       when "packing_list"
                         "documents/packing_list_pdf"
                       when "new_si"
                         "documents/new_si_pdf"
                       else
                         "documents/#{@document_type}_pdf"
                       end
        
        pdf_filename = if @input
                         "#{@document_type}_input_#{@input.id}"
                       else
                         "#{@document_type}_#{@order_entry&.order_no || @dispatch&.d_id}"
                       end
        
        render pdf: pdf_filename,
               template: template_name,
               layout: "pdf",
               formats: [:html],
               page_size: 'A4',
               encoding: "UTF-8",
               show_as_html: params.key?('debug')
      end
    end
  end

  def get_order_details
    @order_entry = OrderEntry.find(params[:order_entry_id])
    render json: {
      order_no: @order_entry.order_no,
      article_no: @order_entry.article_no,
      client_name: @order_entry.client&.name,
      location: @order_entry.location&.name,
      qty: @order_entry.qty,
      target_date: @order_entry.target_date
    }
  end
end
