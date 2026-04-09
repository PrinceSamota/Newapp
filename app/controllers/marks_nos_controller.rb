class MarksNosController < ApplicationController
  def create
    @marks_no = MarksNo.new(marks_no_params)
    @marks_no.org_id = current_user.org_id

    detail_index = params[:detail_index]

    if @marks_no.save
      render turbo_stream: turbo_stream.replace(
        "marks_no_section_#{detail_index}",   # 👈 dynamic id
        partial: "inputs/marks_no_dropdown",
        locals: {
          detail_index: detail_index,
          selected_marks_no_id: @marks_no.id,  # ✅ auto select
          show_form: false,
          errors: []
        }
      )
    else
      render turbo_stream: turbo_stream.replace(
        "marks_no_section_#{detail_index}",
        partial: "inputs/marks_no_dropdown",
        locals: {
          detail_index: detail_index,
          selected_marks_no_id: nil,
          show_form: true,
          errors: @marks_no.errors.full_messages
        }
      )
    end
  end

  private

  def marks_no_params
    params.require(:marks_no).permit(:name)
  end
end