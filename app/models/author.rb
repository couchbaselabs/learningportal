class Author < Couchbase::Model

  attr_accessor :name, :contributions_count
  @@keys = [:name, :contributions_count, :contributions_by_type]
  view :by_contribution_count, :contributions_by_type, :by_first_letter

  def self.popular(limit=8)
    begin
      contribs = Couch.client(:bucket => 'system').get("contributors")["contributors"]
      return contribs.map! { |contrib| new (contrib) }
    rescue Couchbase::Error::NotFound
      Delayed::Job.enqueue(TopContributorsJob.new(limit))
      return []
    end
  end

  def self.by_first_letter(letter="", opts={})
    letter = letter.downcase
    options = { :group => true, :startkey => [letter, ""], :endkey => [letter, "\u9999"] }.merge!(opts)

    results = Couch.client.design_docs["author"].by_first_letter(options).entries
    results.map { |result| new(:name => result.key[1]) }
  end

  def self.by_first_letter_count(letter="", opts={})
    letter = letter.downcase
    options = { :group => false, :startkey => [letter, ""], :endkey => [letter, "\u9999"] }.merge!(opts)
    Couch.client.design_docs["author"].by_first_letter(options).entries.first.value
  end

  def contributions_by_type
    return @contribs if @contribs.present?
    @contribs = { :overall => 0, :image => 0, :video => 0, :text => 0 }
    Couch.client.design_docs["author"].contributions_by_type(:group => true, :reduce => true, :startkey => [name, ""], :endkey => [name, "\u9999"]).entries.each do |row|
      @contribs[row.key[1].to_sym] = row.value
      @contribs[:overall] += row.value
    end
    @contribs
  end

  def initialize(attributes = {})
    @errors = ActiveModel::Errors.new(self)
    attributes.each do |key, value|
      next unless @@keys.include?(key.to_sym)
      send("#{key}=", value)
    end
    self.contributions_count ||= 0
  end

  def contributions_by_type=(value={ :overall => 0, :image => 0, :video => 0, :text => 0 })
    @contribs = value.symbolize_keys unless value.nil?
  end

  def to_s
    name
  end

  def to_json
    {
      name: name,
      contributions_count: contributions_count,
      contributions_by_type: contributions_by_type
    }
  end

end