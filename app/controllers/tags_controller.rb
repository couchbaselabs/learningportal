class TagsController < ApplicationController

  def by_first_letter
    @letter = params[:letter].upcase
    @categories = Category.by_first_letter(@letter)
    render "by_first_letter.js"
  end

  def show
    @authors = Author.popular.take(8)
    @categories = Category.popular.take(10)
    @items = Article.category(params[:id])
    @category = params[:id]
  end

end