class DispatchesController < ApplicationController
  def index
    @dispatches = Dispatch.order(created_at: :desc)
    @dispatch = Dispatch.new
  end

  def new
    @dispatch = Dispatch.new
    render layout: false
  end

  def create
    @dispatch = Dispatch.new(dispatch_params)
    if @dispatch.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to dispatches_path, notice: "Dispatch created successfully." }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end
  def edit
    @dispatch = Dispatch.find(params[:id])
  end
  
  def update
    @dispatch = Dispatch.find(params[:id])
    if @dispatch.update(dispatch_params)
      redirect_to dispatches_path, notice: "Dispatch updated successfully."
    else
      render :edit
    end
  end
  private

  def dispatch_params
    params.require(:dispatch).permit(:order_no, :quantity,  :client_id, :mode_of_shipment, :dispatch_date, :delivery_date, :courier_company)
  end
end
