class MarksNosController < ApplicationController
  def create
    @marks_no = MarksNo.new(marks_no_params)
    @marks_no.org_id = current_user.org_id

    if @marks_no.save
      render partial: 'inputs/marks_no_dropdown',
             locals: { selected_marks_no_id: @marks_no.id, show_form: false, errors: [] },
             formats: [:html]
    else
      render partial: 'inputs/marks_no_dropdown',
             locals: { selected_marks_no_id: nil, show_form: true, errors: @marks_no.errors.full_messages },
             formats: [:html]
    end
  end

  private

  def marks_no_params
    params.require(:marks_no).permit(:name)
  end
end
