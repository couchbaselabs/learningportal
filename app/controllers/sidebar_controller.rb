class SidebarController < ApplicationController

  def all_tags
    @categories = Category.popular.take(10)

    respond_to do |format|
      format.js { render :layout => false }
    end
  end

end