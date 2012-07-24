class Admin::ArticlesController < AdminController

  def index
    @total      = Article.view_stats[:count]
    @per_page   = 10

    @descending = params[:descending] == "true" || params[:descending].nil? ? true : false
    @skip       = @descending == true ? 0 : @per_page

    options = { :limit => @per_page + 1, :include_docs => true, :skip => @skip, :descending => @descending }

    # get documents from particular key and id
    if params[:after_key].present? && params[:after_id].present?
      options.merge!(:start_key => params[:after_key].to_i, :startkey_docid => params[:after_id])
    end

    # get n+1 docs so we can display n and use the n+1th to be the basis of the next pagination set
    @articles     = Article.popular(options).entries

    # if going back a page we need to reverse the results for display
    if @descending == false
      @articles = @articles.reverse
    end

    # should we show next/prev links?
    @has_next = @descending == true && @articles.count < @per_page + 1
    @has_prev = @descending == false && @articles.count < @per_page + 1

    # chop off the n+1th to form the next/previous links
    @next_article = @articles.slice! -1

    if @next_article.present?
      @next_id      = @next_article.id
      @next_key     = @next_article.popularity
    end
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])
    @tag = params[:article][:new_category]

    respond_to do |format|
      if @article.update_attributes(params[:article])
        format.html { redirect_to(admin_articles_path, :notice => '<strong>Success!</strong> Article was successfully updated.'.html_safe) }
        format.xml  { head :ok }
        format.js   { render :layout => false }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @article.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @article = Article.find(params[:id])
    @article.destroy

    redirect_to(admin_articles_url, :notice => '<strong>Success!</strong> Article was successfully deleted.'.html_safe)
  end

end