class DriverRevisionsController < ApplicationController
  def create
    @driver_revision = DriverRevision.new(driver_revision_params)
    @driver_revision.org_id = current_user.org_id

    @driver_revisions = DriverRevision.where(org_id: current_user.org_id)

    if @driver_revision.save
      render turbo_stream: turbo_stream.replace(
        "driver_revision_section",
        partial: "uploads/driver_dropdown",
        locals: {
          selected_driver_revision_id: @driver_revision.id,
          show_form: false,
          driver_revision_errors: []
        }
      )
    else
      render turbo_stream: turbo_stream.replace(
        "driver_revision_section",
        partial: "uploads/driver_dropdown",
        locals: {
          selected_driver_revision_id: nil,
          show_form: true,
          driver_revision_errors: @driver_revision.errors.full_messages
        }
      )
    end
  end

  private

  def driver_revision_params
    params.require(:driver_revision).permit(:name)
  end
end
