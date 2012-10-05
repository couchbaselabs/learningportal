require 'tire/queries/custom_filters_score'

class Article < Couchbase::Model

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Callbacks
  extend ActiveModel::Naming

  view :by_type, :by_category, :by_author, :view_stats, :by_popularity_and_type, :by_popularity, :by_popularity_sum, :by_category_stats, :view_stats_by_type

  @@view_stats    = nil
  @@views_by_type = nil

  def persisted?
    @id
  end

  #attr_accessor :id, :meta, :title, :type, :url, :authors, :contributors, :content, :categories, :attrs, :views, :popularity, :quality
  attribute :id, :title, :type, :url, :authors, :contributors, :content, :categories, :attrs, :views, :popularity, :quality

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

    # popularity and preference boosting power
    @term[:popularity]  = (@term[:popularity].to_i  / 100.0).round(2)
    @term[:preferences] = (@term[:preferences].to_i / 100.0).round(2)

    stats = Article.view_stats
    avg_popularity = stats[:avg]
    max_popularity = stats[:max]

    begin
      Tire.configure do
        url ENV["ELASTIC_SEARCH_URL"]
      end
      s = Tire.search("learning_portal") do |search|

        search.query do |query|

          # query.string "#{@main_query}"

          if @term[:popularity] > 0 && avg_popularity > 0
            script = { script: "_score * (((doc['popularity'].value + 1) / #{avg_popularity} ) * #{@term[:popularity]})" }
          else
            script = { script: "_score"}
          end

          # custom scoring query with logical and matching for advanced search
          query.custom_score(script) do |custom_query|
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

              # score.query { |query| query.string "#{@main_query}" }

              score.filter do |filters|
                filters.filter :term, :type => "video"
                if @term[:preferences] > 0
                  filters.boost (User.current.preferences["types"]["video"]) * @term[:preferences] + 1
                else
                  filters.boost 1
                end
              end

              score.filter do |filters|
                filters.filter :term, :type => "image"
                if @term[:preferences] > 0
                  filters.boost (User.current.preferences["types"]["image"]) * @term[:preferences] + 1
                else
                  filters.boost 1
                end
              end

              score.filter do |filters|
                filters.filter :term, :type => "text"
                if @term[:preferences] > 0
                  filters.boost (User.current.preferences["types"]["text"]) * @term[:preferences] + 1
                else
                  filters.boost 1
                end
              end
              score.score_mode "total"
            end
          end

        end

        # we may not want this, or at least use a different analyzer
        #search.facet "title" do
        #  terms :title
        #end

        # we may not want this, or at least use a different analyzer
        #search.facet "content" do
        #  terms :content
        #end

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
    rescue Couchbase::Error::NotFound
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
    return @@view_stats unless @@view_stats.nil?

    defaults = {:sum => 0, :count => 0, :sumsqr => 0, :min => 0, :max => 0}
    results = {}

    begin
      results = Couch.client.design_docs["article"].view_stats(:reduce => true).entries.first.value.symbolize_keys
    rescue
      # silently fail
    end

    results = defaults.merge!(results)
    if results[:count] == 0
      results[:avg] = 0
    else
      results[:avg] = (results[:sum].to_f/results[:count].to_f)
    end
    @@view_stats = results
  end

  # gathers view total counts by type from content documents in default bucket
  def self.views_by_type(opts={})
    return @@views_by_type unless @@views_by_type.nil?

    options = { :group => true, :reduce => true }.merge!(opts)
    results = Couch.client.design_docs["article"].view_stats_by_type(options).entries

    @@views_by_type = { :text => 0, :video => 0, :image => 0 }
    results.each do |r|
      next if r.key == nil
      @@views_by_type[r.key] = r.value
    end
    @@views_by_type.symbolize_keys!
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
    if type && !(opts.include?(:startkey) || opts.include?(:start_key))
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
      if (name == "new_category" || name == "delete_category") && !value.present?
        attributes.delete(name)
      end
    end
    super
  end

  def new_category; nil; end
  def delete_category; nil; end

  def delete_category=(category)
    self.categories.delete(category) if self.categories.include?(category)
  end

  def new_category=(category)
    self.categories << category
  end

  def self.random
    id = nil
    begin
      startkey = ""

      3.times do
        startkey += rand(10).to_s
      end

      options = { :reduce => false, :include_docs => false, :startkey => startkey, :limit => 1, :skip => rand(25) }
      results = Couch.client.design_docs["article"].view_stats(options)

      id = results.first.id rescue nil
    end while id.nil?

    find(id)
  end

  def initialize(attributes={})

    super

    self.views = self.views || 0
    self.popularity = self.popularity || 0
    self.categories = self.categories || []
  end

  def update
    @attrs.merge!(:categories => @categories, :title => @title, :content => @content, :views => @views, :popularity => @popularity)
    Couch.client.set(@id, @attrs)
  end

  def destroy
    # clone this document to be 'soft deleted' into the system bucket
    doc = self.as_json

    # remove from default bucket
    Couch.client.delete(@id)

    # TODO we should not have to delete directly from elastic search but instead
    #      should be able to rely on the TAP function in couchbase, however
    #      currently this event is not replicated to elastic search via the river
    #
    # remove from elasticsearch index
    Typhoeus::Request.delete("#{ENV['ELASTIC_SEARCH_URL']}/learning_portal/lp_v1/#{id}?refresh=true")

    # wait period to give delete chance to take effect
    sleep 3

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

  def quality
    stats   = Article.view_stats
    quality = ((popularity.to_f - stats[:min].to_f) / stats[:max].to_f * 100).round(2)
    quality.nan? || quality.infinite? ? 0.0 : quality
  end

  def image?
    type == "image"
  end

  def video?
    type == "video"
  end

  def text?
    type == "text"
  end

end