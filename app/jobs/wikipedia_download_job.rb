class WikipediaDownloadJob

  def initialize(article_ids)
    @article_ids = article_ids
  end

  def perform
    articles = Wikipedia.fetch( @article_ids )
    couchbase = Couchbase.connect(ENV["COUCHBASE_URL"])
    articles.each do |article|
      id, document = Wikipedia.parse( article )
      couchbase.set(id.to_s, document)
    end
  end

end