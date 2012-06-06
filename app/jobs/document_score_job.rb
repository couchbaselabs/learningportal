class DocumentScoreJob

  # TODO: Want to handle documents that are not design documents etc.
  def initialize(document_id)
    @document_id = document_id
  end

  def perform
    # 1. what is the maximum amount of views of a piece of content
    #    => 100
    max_views = Article.view_stats[:max]

    # 2. what is the amount of views for this document?
    #    => 1
    views = 0
    begin
      result = Couch.client(:bucket => "views").get("view_count_#{@document_id}")
      views = result['count'] || 0
    rescue Couchbase::Error::NotFound
      # do nothing! we are already 0
    end
    document = Article.find(@document_id)

    # 3. popularity score is as an integer percentage of the max views (rounded up) between 0..100
    #    => 1
    score = 0
    if views >= max_views
      score = 100
    else
      score = ((views.to_f/max_views.to_f)*100).to_i
    end

    # 4. update the document
    document.update_attributes(:views => views, :popularity => score)
  end

end