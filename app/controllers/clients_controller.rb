class ClientsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client, only: [:edit, :update]

  def index
    @clients = Client.where(org_id: current_user.org_id).order(created_at: :desc)
  end

  def edit
  end

  def update
    if @client.update(client_params)
      redirect_to clients_path, notice: 'Client updated successfully.'
    else
      render :edit
    end
  end

  def create
    @client = Client.new(client_params.merge(org_id: current_user.org_id))
  
    if @client.save
      @clients = Client.where(org_id: current_user.org_id)
      render partial: 'uploads/client_dropdown',
             locals: { selected_client_id: @client.id, show_form: false, errors: nil },
             formats: [:html]  
    else
      @clients = Client.where(org_id: current_user.org_id)
      render partial: 'uploads/client_dropdown',
             locals: { selected_client_id: nil, show_form: true, errors: @client.errors.full_messages },
             formats: [:html]  
    end
  end

  private

  def set_client
    @client = Client.find(params[:id])
  end

  def client_params
    params.require(:client).permit(:name, :address)
  end
end
