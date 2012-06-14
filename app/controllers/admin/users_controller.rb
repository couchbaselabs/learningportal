class Admin::UsersController < AdminController

  def index
    @users = User.order("created_at DESC").page(params[:page])
  end

  def login_as
    #return unless current_user.is_an_admin?
    sign_in User.find(params[:user_id]), :bypass => true
    redirect_to root_url # or user_root_url
  end

  def login_as_random
    sign_in User.offset(rand(User.count)).first, :bypass => true
    redirect_to root_url
  end

end