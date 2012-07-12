class ArticlesController < ApplicationController

  before_filter :fetch_authors_and_categories, :only => [:popular, :index, :show]
  after_filter  :limit_endless_scroll, :only => [:index]

  def popular
    @total    = Article.view_stats[:count]
    @per_page = 10
    @page     = (params[:page] || 1).to_i
    @skip     = (@page - 1) * @per_page

    @items = Article.popular(:limit => @per_page, :skip => @skip, :include_docs => true).entries
    # @items = WillPaginate::Collection.create(@page, @per_page, @total) do |pager|
      # pager.replace(@items.to_a)
    # end

    respond_to do |format|
      format.html { render }
      format.js   { render :partial => "shared/endless_scroll.js" }
    end
  end

  def index
    type = case params[:type]
    when "articles"
      "text"
    when "videos"
      "video"
    when "images"
      "image"
    end

    # @items = Article.popular_by_type(type).take(10)
    @total    = Article.view_stats[:count]
    @per_page = 10
    @page     = (params[:page] || 1).to_i
    @skip     = (@page - 1) * @per_page

    @items = Article.popular_by_type(:limit => @per_page, :skip => @skip, :type => type).entries
    # @items = WillPaginate::Collection.create(@page, @per_page, @total) do |pager|
      # pager.replace(@items.to_a)
    # end

    respond_to do |format|
      format.html { render }
      format.js   { render :partial => "shared/endless_scroll.js" }
    end
  end

  def show
    count_view = params[:id].nil? && request.method == "application/json"

    # presume that we want a random article if there's no id
    if params[:id].nil?
      @article = Article.random
    else
      @article = Article.find(params[:id])
    end

    @view_count = @article.count_as_viewed if count_view

    wiki = WikiCloth::Parser.new({
      :data => @article['content']
    })
    @content = Sanitize.clean(wiki.to_html, :elements => ['p', 'ul', 'li', 'i', 'h2', 'h3'], :remove_contents => ['table', 'div']).gsub(/\[[A-z0-9]+\]/, '')

    if current_user && count_view
      if current_user.preferences
        current_user.increment!(@article['type'])
        Event.new(:type => Event::ACCESS, :user => current_user.email, :resource => @article.id.to_s).save
      end
      # current_user.save
    end

    respond_to do |format|
      format.json { render :json => { :url => article_path(@article.id, :only_path => false ) } }
      format.html { render }
    end
  end

  def update
    @article = Article.find(params[:id])
    @article.update_attributes(params[:article])
    @tag = params[:article][:new_category]

    Event.new(:type => Event::TAGGED, :user => current_user.email, :resource => @article.id.to_s).save

    respond_to do |format|
      format.html { redirect_to(@article, :notice => '<strong>Success!</strong> Article was successfully updated.'.html_safe) }
      format.js   { render :layout => false }
    end
  end

end