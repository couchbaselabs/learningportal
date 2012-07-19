class Admin::ArticlesController < AdminController

  def index
    @total      = Article.view_stats[:count]
    @per_page   = 10
    @page       = (params[:page] || 1).to_i
    @after_key  = params[:after_key]
    @after_id   = params[:after_id]
    # @skip     = (@page - 1) * @per_page

    options = { :limit => @per_page, :include_docs => true, :inclusive_end => false }

    # get documents from particular key and id
    if @after_key.present? && @after_id.present?
      session[:after_id]  = @after_id  unless @after_id  == session[:after_id]
      session[:after_key] = @after_key unless @after_key == session[:after_key]

      options.merge!(:start_key => @after_key.to_i, :startkey_docid => @after_id, :skip => 1)
    end

    # get 11 docs so we can display 10 and use the 11th to be the basis of the next pagination set
    @articles = Article.popular(options).entries
    @next_article = { :after_id => @articles.last.id, :after_key => @articles.last.popularity }
    @articles.slice! 10
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