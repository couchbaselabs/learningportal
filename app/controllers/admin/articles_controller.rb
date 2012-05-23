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

    respond_to do |format|
      if @article.update_attributes(params[:article])
        format.html { redirect_to(@article, :notice => 'Article was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @article.errors, :status => :unprocessable_entity }
      end
    end
  end

end