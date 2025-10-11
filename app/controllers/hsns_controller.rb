class HsnsController < ApplicationController
  def create
    @hsn = Hsn.new(hsn_params)
    @hsn.org_id = current_user.org_id

    if @hsn.save
      render turbo_stream: turbo_stream.update("hsn_section", partial: "inputs/hsn_dropdown", locals: {
        selected_hsn_id: @hsn.id,
        show_form: false,
        errors: []
      })
    else
      render turbo_stream: turbo_stream.update("hsn_section", partial: "inputs/hsn_dropdown", locals: {
        selected_hsn_id: nil,
        show_form: true,
        errors: @hsn.errors.full_messages
      })
    end
  end

  private

  def hsn_params
    params.require(:hsn).permit(:name)
  end
end