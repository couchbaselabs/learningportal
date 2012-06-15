class TagsController < ApplicationController

  before_filter :fetch_authors_and_categories, :only => [:show]
  after_filter  :limit_endless_scroll, :only => [:show]

  def by_first_letter
    @letter = params[:letter].upcase

    @total      = Category.by_first_letter_count(@letter)
    @per_page   = 25
    @page       = (params[:page] || 1).to_i
    @skip       = (@page - 1) * @per_page

    @categories = Category.by_first_letter(@letter, { :limit => @per_page, :skip => @skip})
    @categories = WillPaginate::Collection.create(@page, @per_page, @total) do |pager|
      pager.replace(@categories.to_a)
    end

    render "by_first_letter.js"
  end

  def show
    @total    = Article.category_count(params[:tag])
    @per_page = 10
    @page     = (params[:page] || 1).to_i
    @skip     = (@page - 1) * @per_page

    @items = Article.category(params[:tag], { :limit => @per_page, :skip => @skip}).entries
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