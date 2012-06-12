class SearchesController < ApplicationController

  before_filter :fetch_authors_and_categories, :only => [:build, :result]
  after_filter  :limit_endless_scroll, :only => [:build]

  def build
    @total    = Article.view_stats[:count]
    @per_page = 10
    @page     = (params[:page] || 1).to_i
    @skip     = (@page - 1) * @per_page

    @items = Article.popular(:limit => @per_page, :skip => @skip, :include_docs => true).entries
    # @items = WillPaginate::Collection.create(@page, @per_page, @total) do |pager|
      # pager.replace(@items.to_a)
    # end

    respond_to do |format|
      format.html { render :build }
      format.js   { render :partial => "shared/endless_scroll.js" }
    end
  end

  # def result
  #   @couchbase = Couchbase.connect(ENV["COUCHBASE_URL"])
  #   @item = @couchbase.get(params[:id])
  #   @authors = Author.popular.take(8)
  #   @categories = Category.popular.take(10)

  #   @article = Article.find(params[:id])

  #   wiki = WikiCloth::Parser.new({
  #     :data => @item['content']
  #   })
  #   @content = Sanitize.clean(wiki.to_html, :elements => ['p', 'ul', 'li', 'i', 'h2', 'h3'], :remove_contents => ['table', 'div']).gsub(/\[[A-z0-9]+\]/, '')

  #   render :result
  # end

  # def show
  #   Tire.configure do
  #     url ENV["ELASTIC_SEARCH_URL"]
  #   end
  #   @documents = []
  #   @search = Tire.search 'couchbase_wiki' do
  #     query do
  #       string '_all:water'
  #     end
  #   end
  #   @search.results.each do |result|
  #     @documents << result
  #   end

  #   @couchbase = Couchbase.connect(ENV["COUCHBASE_URL"])
  #   @document = @couchbase.get('00411460f7c92d21')
  #   @authors = popular_authors
  #   #@document = nil
  #   #@couchbase.run do |conn|
  #   #  @document = conn.get("00411460f7c92d21")
  #   #end
  # end

end