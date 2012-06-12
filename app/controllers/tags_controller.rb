class TagsController < ApplicationController

  before_filter :fetch_authors_and_categories, :only => [:show]
  after_filter  :limit_endless_scroll, :only => [:show]

  def by_first_letter
    @letter = params[:letter].upcase
    @categories = Category.by_first_letter(@letter)
    render "by_first_letter.js"
  end

  def show
    @total    = Article.category_count(params[:tag])
    @per_page = 10
    @page     = (params[:page] || 1).to_i
    @skip     = (@page - 1) * @per_page

    @items = Article.category(params[:tag], { :limit => @per_page, :skip => @skip, :stale => false }).entries
    # @items = WillPaginate::Collection.create(@page, @per_page, @total) do |pager|
      # pager.replace(@items.to_a)
    # end

    @category = params[:tag]

    respond_to do |format|
      format.html { render }
      format.js   { render :partial => "shared/endless_scroll.js" }
    end

  end

end