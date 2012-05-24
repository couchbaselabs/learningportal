class ArticlesController < ApplicationController

  def show
    @article = Article.find(params[:id])
    @view_count = @article.count_as_viewed

    @authors = Author.popular.take(8)
    @categories = Category.popular.take(10)

    wiki = WikiCloth::Parser.new({
      :data => @article['content']
    })
    @content = Sanitize.clean(wiki.to_html, :elements => ['p', 'ul', 'li', 'i', 'h2', 'h3'], :remove_contents => ['table', 'div']).gsub(/\[[A-z0-9]+\]/, '')

    if current_user
      if current_user.preferences
        current_user.preferences.concat(@article['categories'])
      else
        current_user.preferences = @article['categories']
      end
      current_user.save
    end
  end

  def update
    @article = Article.find(params[:id])
    @article.update_attributes(params[:article])

    redirect_to(@article, :notice => '<strong>Success!</strong> Article was successfully updated.'.html_safe)
  end

end