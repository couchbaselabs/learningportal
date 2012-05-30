class ArticlesController < ApplicationController

  before_filter :fetch_authors_and_categories, :only => [:index, :show]

  def index
    type = case params[:type]
    when "articles"
      "text"
    when "videos"
      "video"
    when "images"
      "audio"
    end

    # @items = Article.popular_by_type(type).take(10)
    @total    = Article.view_stats[:count]
    @per_page = 10
    @page     = (params[:page] || 1).to_i
    @skip     = (@page - 1) * @per_page

    @items = Article.popular_by_type(:limit => @per_page, :skip => @skip, :type => type).entries
    @items = WillPaginate::Collection.create(@page, @per_page, @total) do |pager|
      pager.replace(@items.to_a)
    end

    respond_to do |format|
      format.html { render }
      format.js   { render :layout => false  }
    end
  end

  def show
    @article = Article.find(params[:id])
    @view_count = @article.count_as_viewed

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
    @tag = params[:article][:new_category]

    respond_to do |format|
      format.html { redirect_to(@article, :notice => '<strong>Success!</strong> Article was successfully updated.'.html_safe) }
      format.js   { render :layout => false }
    end
  end

end