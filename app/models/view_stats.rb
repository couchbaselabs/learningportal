class ViewStats < Couchbase::Model

  # We want to make sure we use the correct views bucket.
  BUCKET = "views"
  self.bucket = Couch.client :bucket => BUCKET

  view :by_popularity, :views_by_type

  def self.popular_content(options={})
    defaults = { :descending => true, :reduce => false, :limit => 1000 }
    options = defaults.merge!(options)
    Couch.client(:bucket => BUCKET).design_docs["view_stats"].by_popularity(options).entries
  end

  # gathers view total counts by type from content documents in views bucket
  def self.views_by_type(opts={})
    options = { :group => true, :reduce => true }.merge!(opts)
    results = Couch.client(:bucket => BUCKET).design_docs["view_stats"].views_by_type(options).entries

    result_hash = { :text => 0, :video => 0, :image => 0 }
    results.each do |r|
      next if r.key == nil
      result_hash[r.key] = r.value
    end
    result_hash.symbolize_keys
  end

end