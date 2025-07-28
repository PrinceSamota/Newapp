class OnboardingsController < ApplicationController
  def index
    
  end
  def upload
    ItemsUploading.new(params[:file]).upload
  end
end
