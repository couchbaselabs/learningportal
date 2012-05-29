class TagsController < ApplicationController

  before_filter :fetch_authors_and_categories, :only => [:show]

  def by_first_letter
    @letter = params[:letter].upcase
    @categories = Category.by_first_letter(@letter)
    render "by_first_letter.js"
  end

  def show
    @items = Article.category(params[:id])
    @category = params[:id]
  end

end