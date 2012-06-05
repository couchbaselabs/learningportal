class AuthorsController < ApplicationController

  before_filter :fetch_authors_and_categories, :only => [:show]

  def by_first_letter
    @letter = params[:letter].upcase
    @authors = Author.by_first_letter(@letter)
    render "by_first_letter.js"
  end

  def show
    @items = Article.author(params[:author])
    @author = params[:author]
  end

end