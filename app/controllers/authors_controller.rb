class AuthorsController < ApplicationController

  def by_first_letter
    @letter = params[:letter].upcase
    @authors = Author.by_first_letter(@letter)
    render "by_first_letter.js"
  end

  def show
    @items = Article.author(params[:id])

    @authors = Author.popular.take(8)
    @categories = Category.popular.take(10)
    @author = params[:id]
  end

end