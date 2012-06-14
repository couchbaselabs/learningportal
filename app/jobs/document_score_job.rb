class DocumentScoreJob

  # TODO: Want to handle documents that are not design documents etc.
  def initialize(document_id)
    @document_id = document_id
  end

  def perform
    # 1. what is the maximum amount of views of a piece of content
    #    => 100
    max_views = Article.view_stats[:max]

    # 2. what is the all time amount of views for this document?
    document = Article.find("#{@document_id}")
    total = document['views'] || 0
    popularity = document['popularity'] || 0

    # 3. what is the recent count of views
    views = 0
    begin
      result = Couch.client(:bucket => "views").get("#{@document_id}")
      views = result['count'] || 0
    rescue Couchbase::Error::NotFound
      # do nothing! we are already 0
    end

    # 4. total
    total = total + views
    popularity = popularity + views

    # 5. update the document with the new all time total and popularity
    document.update_attributes(:views => total, :popularity => popularity)

    # 6. reset the counter
    Couch.client(:bucket => "views").set("#{@document_id}", {:count => 0, :type => document.type})
  end

end
