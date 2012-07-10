require 'tire/queries/custom_filters_score'

class Article < Couchbase::Model

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Callbacks
  extend ActiveModel::Naming

  view :by_type, :by_category, :by_author, :view_stats, :by_popularity_and_type, :by_popularity, :by_category_stats, :view_stats_by_type

  def persisted?
    @id
  end

  attr_accessor :id, :title, :type, :url, :author, :contributors, :content, :categories, :attrs, :views, :popularity
  @@keys = [:id, :title, :type, :url, :author, :contributors, :content, :categories, :attrs, :views, :popularity]

  def self.search(term={}, options={})
    ids = []
    results = {
      :results => [],
      :total_results => 0
    }
    @term = term.symbolize_keys

    # parameterize a main query if only advanced options are provided
    # into 'title:title search '
    if @term[:q].empty?
      @main_query = @term.reject { |k,v| (k == :q || v.empty?) }.map { |k,v| "#{k}:\"#{v}\"" }.join " "
    else
      @main_query = @term[:q]
    end

    begin
      Tire.configure do
        url ENV["ELASTIC_SEARCH_URL"]
      end
      s = Tire.search("learning_portal") do |search|
        search.query do |query|

          query.string "#{@main_query}"

          # custom scoring query with logical and matching for advanced search
          query.custom_score script: "_score * (doc['popularity'] + 1)" do |custom_query|
            custom_query.custom_filters_score do |score|
              score.query do |score_query|
                score_query.boolean do |bool|
                  # Search All on the normal field
                  bool.must { |must| must.string "#{@main_query}" }

                  bool.must { |must| must.string "title:#{@term[:title]}" }                    if @term[:title].present?
                  bool.must { |must| must.string "content:#{@term[:content]}" }                if @term[:content].present?
                  bool.must { |must| must.string "authors.name:#{@term[:author]}" }            if @term[:author].present?
                  bool.must { |must| must.string "contributors.name:#{@term[:contributor]}" }  if @term[:contributor].present?
                  bool.must { |must| must.string "categories:#{@term[:category]}" }            if @term[:category].present?
                  bool.must { |must| must.string "type:#{@term[:type]}" }                      if @term[:type].present?
                end
              end

              score.filter do
                filter :term, :type => "video"
                boost User.current.preferences["types"]["video"] + 1
              end

              score.filter do
                filter :term, :type => "image"
                boost User.current.preferences["types"]["image"] + 1
              end

              score.filter do
                filter :term, :type => "text"
                boost User.current.preferences["types"]["text"] + 1
              end
              score.score_mode "first"
            end
          end

        end

        # we may not want this, or at least use a different analyzer
        search.facet "title" do
          terms :title
        end

        # we may not want this, or at least use a different analyzer
        search.facet "content" do
          terms :content
        end

        search.facet "authors" do
          terms :authors, :field => "authors.name"
        end

        search.facet "contributors" do
          terms :contributors, :field => "contributors.name"
        end

        # currently 'breaks' tags down into each of their keywords rather than
        # based on the whole tag. e.g. "Living people" - becomes - ["living", "people"]
        search.facet "tags" do
          terms :categories
        end

        search.facet "type" do
          terms :type
        end

        # limit results
        search.size options[:size] || 10
        search.from options[:from] || 0
      end

      ids = s.results.take(25).collect(&:id)

      results[:results]       = ids.map! { |id| find(id) }
      results[:total_results] = s.results.total
      results[:raw_search]    = s

    rescue Tire::Search::SearchRequestFailed
    rescue RestClient::Exception
      # Search failed!
    end

    return results

    # BUG!
    # Causes bug in couchbase client where it hangs the Ruby process
    # indefinitely and can only fixed by killing the process.
    #
    # docs = Couch.client(:bucket => "default").all_docs(:keys => ids, :include_docs => true)
  end

  def self.totals
    total = { :overall => 0, :image => 0, :video => 0, :text => 0 }
    Couch.client.design_docs["article"].by_type(:group => true, :group_level => 1).entries.each do |row|
      total[row.key[0].to_sym] = row.value
      total[:overall]   += row.value
    end
    total
  end

  def self.view_stats
    defaults = {:sum => 0, :count => 0, :sumsqr => 0, :min => 0, :max => 0}
    results = {}
    begin
      results = Couch.client.design_docs["article"].view_stats(:reduce => true).entries.first.value.symbolize_keys
    rescue

    end
    results = defaults.merge!(results)
    if results[:count] == 0
      results[:avg] = 0
    else
      results[:avg] = (results[:sum].to_f/results[:count].to_f)
    end
    results
  end

  # gathers view total counts by type from content documents in default bucket
  def self.views_by_type(opts={})
    options = { :group => true, :reduce => true }.merge!(opts)
    results = Couch.client.design_docs["article"].view_stats_by_type(options).entries

    result_hash = { :text => 0, :video => 0, :image => 0 }
    results.each do |r|
      next if r.key == nil
      result_hash[r.key] = r.value
    end
    result_hash.symbolize_keys
  end

  def self.author(a, opts={})
    # Couch.client.design_docs["article"].by_type(:reduce => false).entries.collect { |row| Article.find(row.key[1]) }
    options = { :reduce => false }.merge!(opts)
    options.merge!({ :startkey => [a, ""], :endkey => [a, "\u9999"] })
    by_author(options).entries
  end

  def self.author_count(a, opts={})
    options = { :startkey => [a, ""], :endkey => [a, "\u9999"], :reduce => true }
    Couch.client.design_docs["article"].by_author(options).entries.first.value rescue 0
  end

  def self.category(c, opts={})
    # Couch.client.design_docs["article"].by_type(:reduce => false).entries.collect { |row| Article.find(row.key[1]) }
    options = { :reduce => false }.merge!(opts)
    options.merge!({ :startkey => [c, ""], :endkey => [c, "\u9999"] })
    by_category(options).entries
  end

  def self.category_count(c)
    options = { :startkey => [c, ""], :endkey => [c, "\u9999"], :reduce => true }
    Couch.client.design_docs["article"].by_category(options).entries.first.value rescue 0
  end

  def self.popular_by_type(opts={})
    # Couch.client.design_docs["article"].by_type(:reduce => false).entries.collect { |row| Article.find(row.key[1]) }
    type = opts.delete(:type)
    options = { :reduce => false, :descending => true, :include_docs => true, :stale => false }.merge(opts)
    if type
      options.merge!({ :startkey => [type, Article.view_stats[:max]], :endkey => [type, 0] })
    end
    by_popularity_and_type(options).entries
  end

  def self.popular(opts={})
    options = { :descending => true, :reduce => false, :include_docs => true, :limit => 10, :stale => false }.merge(opts)
    by_popularity(options).entries
  end

  def update_attributes(attributes)
    attributes.each do |name, value|
      next if (name == "new_category" || name == "delete_category") && !value.present?
      # next unless @@keys.include?(name.to_sym)
      send("#{name}=", value)
    end
    update
  end

  def [](key)
    attrs[key]
  end

  def new_category; nil; end
  def delete_category; nil; end

  def delete_category=(category)
    self.categories.delete(category) if self.categories.include?(category)
  end

  def new_category=(category)
    self.categories << category
  end

  def self.find(id)
    id = id.to_s if id.respond_to?(:to_s)
    new( Couch.client.get(id).merge("id" => id) )
  end

  def initialize(attributes={})
    @errors = ActiveModel::Errors.new(self)

    attributes.each do |name, value|
      next unless @@keys.include?(name.to_sym)
      send("#{name}=", value)
    end

    self.attrs = attributes.with_indifferent_access || {}
    self.views = self.attrs[:views] || 0
    self.popularity = self.attrs[:popularity] || 0
    self.categories = self.attrs[:categories] || []
  end

  def update
    @attrs.merge!(:categories => @categories, :title => @title, :content => @content, :views => @views, :popularity => @popularity)
    Couch.client.set(@id, @attrs)
  end

  def destroy
    # clone this document to be 'soft deleted' into the system bucket
    doc = self.as_json

    # remove from elasticsearch index
    Typhoeus::Request.delete("#{ENV['ELASTIC_SEARCH_URL']}/learning_portal/lp_v1/#{id}?refresh=true")

    # remove from default bucket
    Couch.client.delete(@id)

    # save a clone of this document into the 'system' bucket
    Couch.client(:bucket => "system").set("#{doc['id']}", doc)
  end

  def count_as_viewed
    period = Couch.client(:bucket => "views")
    global = Couch.client(:bucket => "global")
    views = 0
    begin
      result = period.get("#{id}")
      views = result['count'] || 0
      views += 1
    rescue Couchbase::Error::NotFound => e
      views = 1
    end
    period.set("#{id}", {:count => views, :type => type})

    begin
      result = global.get("#{id}")
      views += result['count']
    rescue Couchbase::Error::NotFound

    end
    views
  end

  def as_json
    self.attrs.as_json
  end

end