class GlobalViewStats < Couchbase::Model

  # We want to make sure we use the correct views bucket.
  cattr_accessor :bucket_name
  self.bucket_name = "global"

  def self.bucket
    Couch.client(:bucket => bucket_name)
  end

  view :by_popularity, :views_by_type

  def self.popular_content(options={})
    defaults = { :descending => true, :reduce => false, :limit => 1000 }
    options = defaults.merge!(options)
    bucket.design_docs["global_view_stats"].by_popularity(options).entries
  end

  # gathers view total counts by type from content documents in views bucket
  def self.views_by_type(opts={}, include_period=false)
    options = { :group => true, :reduce => true }.merge!(opts)
    results = bucket.design_docs["global_view_stats"].views_by_type(options).entries

    global = { :text => 0, :video => 0, :image => 0 }
    results.each do |r|
      next if r.key == nil
      global[r.key.to_sym] = r.value
    end

    if include_period
      period = PeriodViewStats.views_by_type(opts)

      global[:text]    = (global[:text]  || 0) + (period[:text]  || 0)
      global[:image]   = (global[:image] || 0) + (period[:image] || 0)
      global[:video]   = (global[:video] || 0) + (period[:video] || 0)
      global[:overall] = global[:text]  + global[:image] + global[:video]
    end

    global
  end

  def self.update_counter(doc, counter)
    Couch.client(:bucket => bucket_name).set("#{doc.id}", { :count => counter, :type => doc.type } )
  end

end