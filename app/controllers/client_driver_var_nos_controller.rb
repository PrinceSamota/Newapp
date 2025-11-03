class ClientDriverVarNosController < ApplicationController
    before_action :authenticate_user!
  
    def create
      @client_driver_var_no = ClientDriverVarNo.new(client_driver_var_no_params)
      @client_driver_var_no.org_id = current_user.org_id if @client_driver_var_no.respond_to?(:org_id)
  
      if @client_driver_var_no.save
        render partial: "uploads/client_driver_ver_no_dropdown", locals: {
          selected_client_driver_var_no_id: @client_driver_var_no.id,
          show_form: false,
          errors: []
        },
        formats: [:html]
      else
        render partial: "uploads/client_driver_ver_no_dropdown", locals: {
          selected_client_driver_var_no_id: nil,
          show_form: true,
          errors: @client_driver_var_no.errors.full_messages
        },
        formats: [:html]
      end
    end
  
    private
  
    def client_driver_var_no_params
      params.require(:client_driver_var_no).permit(:name)
    end
  end
  