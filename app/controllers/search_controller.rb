class SearchController < ApplicationController

  before_filter :fetch_authors_and_categories, :only => [:build]
  after_filter  :limit_endless_scroll, :only => [:build]

  def build
    @per_page = 10
    @page     = (params[:page] || 1).to_i
    @skip     = (@page - 1) * @per_page

    @search = Article.search(@search_terms, :from => @skip, :size => @per_page)
    @items  = @search[:results]
    @total  = @search[:total_results]
    @search = @search[:raw_search]

    respond_to do |format|
      format.html { render }
      format.js   { render :partial => "shared/endless_scroll.js" }
    end
  end

end