# app/controllers/clients_controller.rb
class ClientsController < ApplicationController
    def create
      @client = Client.new(client_params.merge(org_id: current_user.org_id))
  
      if @client.save
        @clients = Client.where(org_id: current_user.org_id)
        render turbo_stream: turbo_stream.replace(
          "client_section",
          partial: "dispatches/client_section",
          locals: { dispatch: Dispatch.new, selected_client_id: @client.id, flash: {} }
        )
      else
        @clients = Client.where(org_id: current_user.org_id)
        render turbo_stream: turbo_stream.replace(
          "client_section",
          partial: "dispatches/client_section",
          locals: { dispatch: Dispatch.new, selected_client_id: nil, flash: { client_errors: @client.errors.full_messages } }
        )
      end
    end
  
    private
  
    def client_params
      params.require(:client).permit(:name)
    end
  end
  