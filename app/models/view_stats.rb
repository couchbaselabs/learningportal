class ViewStats < Couchbase::Model

  # We want to make sure we use the correct views bucket.
  BUCKET = "views"
  self.bucket = Couch.client :bucket => BUCKET

  view :by_popularity

  def self.popular_content(opts={ :limit => 1000 })
    options = opts.merge!({ :descending => true, :reduce => false })
    Couch.client(:bucket => BUCKET).design_docs["view_stats"].by_popularity(options).entries
  end

end