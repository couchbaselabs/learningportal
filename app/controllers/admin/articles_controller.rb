class Admin::ArticlesController < AdminController

  def index
    @total    = Article.view_stats[:count]
    @per_page = 10
    @page     = (params[:page] || 1).to_i
    @skip     = (@page - 1) * @per_page

    @articles = Article.popular(:limit => @per_page, :skip => @skip, :include_docs => true).entries
    @articles = WillPaginate::Collection.create(@page, @per_page, @total) do |pager|
      pager.replace(@articles.to_a)
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

    respond_to do |format|
      format.html { redirect_to(admin_articles_url, :notice => '<strong>Success!</strong> Article was successfully deleted.'.html_safe) }
    end
  end

end