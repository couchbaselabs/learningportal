class Admin::ArticlesController < ApplicationController

  layout "admin"

  def index
    @couchbase = Couchbase.connect(ENV["COUCHBASE_URL"])
    @articles = @couchbase.all_docs(:include_docs => true, :limit => 5).entries
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