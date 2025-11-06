class CurrenciesController < ApplicationController
    def create
      @currency = Currency.new(currency_params)
      @currency.org_id = current_user.org_id if @currency.respond_to?(:org_id=)
  
      if @currency.save
        render turbo_stream: turbo_stream.update("currency_section", partial: "inputs/currency_dropdown", locals: {
          selected_currency_id: @currency.id,
          show_form: false,
          errors: []
        })
      else
        render turbo_stream: turbo_stream.update("currency_section", partial: "inputs/currency_dropdown", locals: {
          selected_currency_id: nil,
          show_form: true,
          errors: @currency.errors.full_messages
        })
      end
    end
  
    private
  
    def currency_params
      params.require(:currency).permit(:name)
    end
  end
  