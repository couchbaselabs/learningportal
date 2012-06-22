class SearchController < ApplicationController

  before_filter :fetch_authors_and_categories, :only => [:build]
  after_filter  :limit_endless_scroll, :only => [:build]

  def build
    @term  = params[:q] || ""
    if @term.blank?
      redirect_to root_path
    end
    @items = Article.search(@term)
    @total = @items.count rescue 0
  end

end