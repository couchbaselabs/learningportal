class ArticlesController < ApplicationController

  before_filter :fetch_authors_and_categories, :only => [:popular, :index, :show]
  before_filter :become_random_user!, :only => [:random]
  after_filter  :limit_endless_scroll, :only => [:index]
  skip_before_filter :authenticate_user!, :only => [:random]

  def popular
    @total    = Article.view_stats[:count]
    @per_page = 10

    # @page     = (params[:page] || 1).to_i
    # @skip     = (@page - 1) * @per_page

    options = { :limit => @per_page + 1, :include_docs => true }

    # get documents from particular key and id
    if params[:after_key].present? && params[:after_id].present?
      options.merge!(:start_key => params[:after_key].to_i, :startkey_docid => params[:after_id])
    end

    @items = Article.popular(options).entries

    # chop off the n+1th to form the next/previous links
    @next_article = @items.slice! -1

    if @next_article.present?
      @next_id      = @next_article.id
      @next_key     = @next_article.popularity
    end

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
    @total    = Article.totals[type.to_sym]
    @per_page = 10

    options = { :limit => @per_page + 1, :include_docs => true, :type => type }

    # get documents from particular key and id
    if params[:after_key].present? && params[:after_id].present?
      options.merge!(:startkey => [type, params[:after_key].to_i], :startkey_docid => params[:after_id])
    end

    @options = options

    @items = Article.popular_by_type(options).entries

    # chop off the n+1th to form the next/previous links
    @next_article = @items.slice! -1

    if @next_article.present?
      @next_id      = @next_article.id
      @next_key     = @next_article.popularity
    end

    respond_to do |format|
      format.html { render }
      format.js   { render :partial => "shared/endless_scroll.js" }
    end
  end

  def show
    @article = Article.find(params[:id])
    @view_count = @article.count_as_viewed

    if @article.text?
      wiki = WikiCloth::Parser.new({
        :data => @article.content
      })
      @content = Sanitize.clean(wiki.to_html, :elements => ['p', 'ul', 'li', 'i', 'h2', 'h3'], :remove_contents => ['table', 'div']).gsub(/\[[A-z0-9]+\]/, '')
    end

    if current_user && current_user.preferences
      current_user.increment!(@article['type'])
    end
    Event.new(:type => Event::ACCESS, :user => (current_user.email rescue nil), :resource => @article.id.to_s).save
  end

  def random
    @article = Article.random

    if request.format.html? || request.format == "*/*"
      @view_count = @article.count_as_viewed

      wiki = WikiCloth::Parser.new({
        :data => @article['content']
      })
      @content = Sanitize.clean(wiki.to_html, :elements => ['p', 'ul', 'li', 'i', 'h2', 'h3'], :remove_contents => ['table', 'div']).gsub(/\[[A-z0-9]+\]/, '')

      if current_user && current_user.preferences
        current_user.increment!(@article['type'])
      end
    end

    Event.new(:type => Event::ACCESS, :user => (current_user.email rescue nil), :resource => @article.id.to_s).save

    respond_to do |format|
      format.html { render 'show' }
      format.json { render :json => { :url => article_path(@article.id, :only_path => false ) } }
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