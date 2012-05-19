class SidebarController < ApplicationController

  def all_tags
    @categories = Category.popular.take(20)

    respond_to do |format|
      format.js { render :layout => false }
    end
  end

  def all_contributors
    @authors = Author.popular.take(15)

    respond_to do |format|
      format.js { render :layout => false }
    end
  end

end