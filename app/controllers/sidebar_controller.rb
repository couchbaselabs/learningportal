class SidebarController < ApplicationController

  before_filter :fetch_authors_and_categories, :only => [:overview]

  def all_tags
    @categories = Category.popular.take(20)

    respond_to do |format|
      format.js { render :layout => false }
    end
  end

  def all_contributors
    # @authors = Author.popular.take(15)
    @authors = []

    respond_to do |format|
      format.js { render :layout => false }
    end
  end

  def overview
    respond_to do |format|
      format.js { render :layout => false }
    end
  end

end