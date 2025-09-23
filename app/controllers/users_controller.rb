
class UsersController < ApplicationController
  before_action :authenticate_user!

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    
    if user_params[:password].present?
      if @user.update_with_password(user_params)
        bypass_sign_in(@user)
        redirect_to root_path, notice: 'Profile updated successfully!'
      else
        render :edit, status: :unprocessable_entity
      end
    else
      if @user.update_without_password(user_params.except(:current_password))
        redirect_to root_path, notice: 'Profile updated successfully!'
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :phone, :address, :org_id, :password, :password_confirmation, :current_password)
  end
end

