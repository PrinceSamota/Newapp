class CompleteDescriptionOfGoodsController < ApplicationController
  def create
    @complete_description_of_good = CompleteDescriptionOfGood.new(complete_description_of_good_params)
    @complete_description_of_good.org_id = current_user.org_id

    if @complete_description_of_good.save
      render turbo_stream: turbo_stream.update("complete_description_section", partial: "inputs/complete_description_dropdown", locals: {
        selected_complete_description_id: @complete_description_of_good.id,
        show_form: false,
        errors: []
      })
    else
      render turbo_stream: turbo_stream.update("complete_description_section", partial: "inputs/complete_description_dropdown", locals: {
        selected_complete_description_id: nil,
        show_form: true,
        errors: @complete_description_of_good.errors.full_messages
      })
    end
  end

  private

  def complete_description_of_good_params
    params.require(:complete_description_of_good).permit(:name)
  end
end