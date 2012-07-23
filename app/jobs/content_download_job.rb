class ContentDownloadJob

  def initialize(article_ids)
    @article_ids = article_ids
  end

  def perform
    articles = Content.fetch( @article_ids )
    avg = 0
    begin
      stats = Article.view_stats
      avg = stats[:avg]
    rescue Couchbase::Error::NotFound

    end

    articles.each do |article|
      id, document = Content.parse( article, avg )
      Couch.client.set(id.to_s, document)
      Event.new(:type => Event::CREATE, :user => nil, :resource => id.to_s).save
    end
  end

end