class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_paper_trail_whodunnit
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :authenticate_user!

  protected

  def configure_permitted_parameters
    # For sign up
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :org_id, :phone, :address, :role])

    # For account update (if needed)
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :org_id, :phone, :address, :role])
  end

  # Role-based access control
  def require_admin
    redirect_to root_path, alert: 'Access denied.' unless current_user&.admin?
  end

  def require_admin_or_manager
    redirect_to root_path, alert: 'Access denied.' unless current_user&.admin? || current_user&.manager?
  end
end
