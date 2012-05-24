class TagsController < ApplicationController

  def by_first_letter
    @letter = params[:letter].upcase
    @categories = Category.by_first_letter(@letter)
    render "by_first_letter.js"
  end

end