class AuthorsController < ApplicationController

  def by_first_letter
    @letter = params[:letter].upcase
    @authors = Author.by_first_letter(@letter)
    render "by_first_letter.js"
  end

  def show
    @authors = Author.popular.take(8)
    @categories = Category.popular.take(10)
    @items = Article.popular_by_type('text').take(10)
  end

end