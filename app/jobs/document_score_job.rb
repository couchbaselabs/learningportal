class DocumentScoreJob

  # TODO: Want to handle documents that are not design documents etc.
  def initialize(document_id)
    @document_id = document_id
  end

  def perform
    # what is the maximum amount of views of a piece of content
    #    => 100
    max_views = Article.view_stats[:max]

    # what is the all time amount of views for this document?
    global_views = 0
    begin
      global       = Couch.client(:bucket => "global").get("#{@document_id}")
      global_views = global['count'] || 0
    rescue Couchbase::Error::NotFound
      # do nothing! we are already 0
    end

    # what is the recent count of views
    period_views = 0
    begin
      period       = Couch.client(:bucket => "views").get("#{@document_id}")
      period_views = period['count'] || 0
    rescue Couchbase::Error::NotFound
      # do nothing! we are already 0
    end

    document     = Article.find("#{@document_id}")
    popularity   = document['popularity'] || 0

    # total
    global_views  = global_views + period_views
    popularity    = popularity   + period_views

    # update the document with the new all time total and popularity
    document.update_attributes(:popularity => popularity)
    document.save

    # store the updated global counter
    GlobalViewStats.update_counter document, global_views

    # reset the period counter
    PeriodViewStats.reset_counter document
  end

end
