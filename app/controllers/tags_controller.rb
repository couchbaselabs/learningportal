class TagsController < ApplicationController

  before_filter :fetch_authors_and_categories, :only => [:show]

  def by_first_letter
    @letter = params[:letter].upcase
    @categories = Category.by_first_letter(@letter)
    render "by_first_letter.js"
  end

  def show
    # this is awkward to implement, we need to do another
    # query with the tag to get info about the *complete*
    # reseult in addition to retrieving the limited subset
    @total    = 0

    @items    = Article.category(params[:tag], { :limit => 50 } )
    @category = params[:tag]
  end

end