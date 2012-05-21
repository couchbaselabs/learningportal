class SearchesController < ApplicationController

protected
  def popular_authors
    #authors = []
    #results = @couchbase.design_docs["author"].author(:group => true).entries
    #results.each do |a|
    #  authors << [a.key, a.value]
    #end
    #authors.sort! {|a,b| a.last <=> b.last}.reverse!
    #authors.take(10)
  end

public

  def build
    @couchbase = Couchbase.connect(ENV["COUCHBASE_URL"])
    @items = @couchbase.all_docs(:include_docs => true, :limit => 5).entries
    @authors = Author.popular.take(8)
    @categories = Category.popular.take(10)
    render :build
  end

  def result
    @couchbase = Couchbase.connect(ENV["COUCHBASE_URL"])
    @item = @couchbase.get(params[:id])
    @authors = Author.popular.take(8)
    @categories = Category.popular.take(10)

    @article = Article.find(params[:id])

    wiki = WikiCloth::Parser.new({
      :data => @item['content']
    })
    @content = Sanitize.clean(wiki.to_html, :elements => ['p', 'ul', 'li', 'i', 'h2', 'h3'], :remove_contents => ['table', 'div']).gsub(/\[[A-z0-9]+\]/, '')

    render :result
  end

  def show
    Tire.configure do
      url ENV["ELASTIC_SEARCH_URL"]
    end
    @documents = []
    @search = Tire.search 'couchbase_wiki' do
      query do
        string '_all:water'
      end
    end
    @search.results.each do |result|
      @documents << result
    end

    @couchbase = Couchbase.connect(ENV["COUCHBASE_URL"])
    @document = @couchbase.get('00411460f7c92d21')
    @authors = popular_authors
    #@document = nil
    #@couchbase.run do |conn|
    #  @document = conn.get("00411460f7c92d21")
    #end
  end


end