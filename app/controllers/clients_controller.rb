class ClientsController < ApplicationController
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

  def client_params
    params.require(:client).permit(:name)
  end
end
