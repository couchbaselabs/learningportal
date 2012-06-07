class WikipediaDownloadJob

  def initialize(article_ids)
    @article_ids = article_ids
  end

  def perform
    articles = Wikipedia.fetch( @article_ids )
    avg = 0
    begin
      stats = Article.view_stats
      avg = stats[:avg]
    rescue Couchbase::Error::NotFound

    end

    articles.each do |article|
      id, document = Wikipedia.parse( article, avg )
      Couch.client.set(id.to_s, document)
    end
  end

end