class AuthorsController < ApplicationController

  before_filter :fetch_authors_and_categories, :only => [:show]
  after_filter  :limit_endless_scroll, :only => [:show]

  def by_first_letter
    @letter = params[:letter].upcase
    @authors = Author.by_first_letter(@letter)
    render "by_first_letter.js"
  end

  def show
    @total    = Article.author_count(params[:author])
    @per_page = 10
    @page     = (params[:page] || 1).to_i
    @skip     = (@page - 1) * @per_page

    @items = Article.author(params[:author], { :limit => @per_page, :skip => @skip }).entries
    # @items = WillPaginate::Collection.create(@page, @per_page, @total) do |pager|
      # pager.replace(@items.to_a)
    # end

    @author = Author.new(:name => params[:author])

    respond_to do |format|
      format.html { render }
      format.js   { render :partial => "shared/endless_scroll.js" }
    end
  end

end