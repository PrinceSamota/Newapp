class InputsController < ApplicationController
  before_action :set_input, only: [:show, :edit, :update, :destroy]

  def index
    @q = Input.order(created_at: :desc).ransack(params[:q])
    @inputs = @q.result(distinct: true).paginate(page: params[:page], per_page: 100)
  end

  def show
    @input = Input.find(params[:id])
  end

  def new
    @input = Input.new
    @input.input_items.build
    @input.input_details.build
    
    # Dispatch se values pass karne ke liye
    if params[:from_dispatch].present? && params[:dispatch_id].present?
      @dispatch = Dispatch.find(params[:dispatch_id])
      @input.dispatch_id = @dispatch.id
      order_numbers = @dispatch.dispatch_items.pluck(:order_no)
      @input.order_no_from_dispatch = order_numbers.join(", ")
      prefill_from_dispatch
    end
  end

  def create
    @input = Input.new(input_params)
    @input.user = current_user
    @input.org_id = current_user.org_id
  
    @input.dispatch_id = params[:dispatch_id] if params[:dispatch_id].present?
  
    if params[:save_draft].present?
      @input.status = "draft"
      if @input.save(validate: false)
        redirect_to edit_input_path(@input), notice: 'Draft saved successfully!'
      else
        redirect_to new_input_path, alert: 'Unable to save draft.'
      end
    else
      @input.status = "completed"
      if @input.save
        redirect_to input_path(@input), notice: 'Input was successfully created.'
      else
        render :new, status: :unprocessable_entity
      end
    end
  end
  
  

  def edit
  end

  def update
    if params[:save_draft].present?
      @input.assign_attributes(input_params)
      @input.status = "draft"
      if @input.save(validate: false)  
        redirect_to input_path(@input), notice: 'Draft updated successfully!'
      else
        redirect_to edit_input_path(@input), alert: 'Unable to save draft.'
      end
    else
      @input.status = "completed"
      if @input.update(input_params)   
        redirect_to input_path(@input), notice: 'Input was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end
  def download_item_pdf
    @item = InputItem.find(params[:item_id])
    @input = @item.input   # Item se parent input fetch karo
  
    respond_to do |format|
      format.pdf do
        render pdf: "input_item_#{@item.id}",
               template: "inputs/item_pdf",
               layout: "pdf",
               formats: [:html]
      end
    end
  end
  
  
  

  def destroy
    @input.destroy
    redirect_to inputs_path, notice: 'Input deleted successfully.'
  end

  private

  def set_input
    @input = Input.find(params[:id])
  end

  def input_params
    params.require(:input).permit(
      :invoice_no, :invoice_date, :shipper_name_id, :consignee_name_id, 
      :importer_name_id, :order_no_from_dispatch, :currency_id, :dispatch_id, :fedex_awb_no,
      input_items_attributes: [
        :id, :no_of_boxes, :description_of_goods_id, :qty_per_box, 
        :net_weight, :gross_weight, :length, :width, :height, :order_no, :_destroy
      ],
      input_details_attributes: [
        :id, :marks_no_id, :no_of_packages, :type_of_package_id, 
        :complete_description_of_good_id, :hsn_id, :qty_pcs, :price, :_destroy
      ]
    )
  end
  
  def prefill_from_dispatch
    @input.invoice_no = @dispatch.invoice_no if @dispatch.invoice_no.present?

  end
end
