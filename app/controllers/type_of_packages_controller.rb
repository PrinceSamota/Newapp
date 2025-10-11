class TypeOfPackagesController < ApplicationController
  def create
    @type_of_package = TypeOfPackage.new(type_of_package_params)
    @type_of_package.org_id = current_user.org_id

    if @type_of_package.save
      render turbo_stream: turbo_stream.update("type_of_package_section", partial: "inputs/type_of_package_dropdown", locals: {
        selected_type_of_package_id: @type_of_package.id,
        show_form: false,
        errors: []
      })
    else
      render turbo_stream: turbo_stream.update("type_of_package_section", partial: "inputs/type_of_package_dropdown", locals: {
        selected_type_of_package_id: nil,
        show_form: true,
        errors: @type_of_package.errors.full_messages
      })
    end
  end

  private

  def type_of_package_params
    params.require(:type_of_package).permit(:name)
  end
end