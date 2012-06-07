class WikipediaDownloadJob

  def initialize(article_ids)
    @article_ids = article_ids
  end

  def perform
    articles = Wikipedia.fetch( @article_ids )
    stats = Article.view_stats

    articles.each do |article|
      id, document = Wikipedia.parse( article, stats[:avg] )
      Couch.client.set(id.to_s, document)
    end
  end

end