class ProfilesController < ApplicationController
    before_action :authenticate_user!
  
    def create
      @profile = Profile.new(profile_params)
      @profile.org_id = current_user.org_id
  
      if @profile.save
        render turbo_stream: turbo_stream.update("profile_section", partial: "uploads/profile_dropdown", locals: {
          selected_profile_id: @profile.id,
          show_form: false,
          errors: []
        })
      else
        render turbo_stream: turbo_stream.update("profile_section", partial: "uploads/profile_dropdown", locals: {
          selected_profile_id: nil,
          show_form: true,
          errors: @profile.errors.full_messages
        })
      end
    end
  
    private
  
    def profile_params
      params.require(:profile).permit(:name)
    end
  end
  