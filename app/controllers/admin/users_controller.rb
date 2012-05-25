class Admin::UsersController < ApplicationController

  layout "admin"

  def index
    @users = User.all
  end

  def login_as
    #return unless current_user.is_an_admin?
    sign_in User.find(params[:user_id]), :bypass => true
    redirect_to root_url # or user_root_url
  end

end