class Author < Couchbase::Model

  attr_accessor :name, :contributions_count
  @@keys = [:name, :contributions_count]
  view :by_contribution_count, :contributions_by_type

  def self.popular
    results = Couch.client.design_docs["author"].by_contribution_count(:descending => true, :group => true).entries
    results.map! { |result| new(:name => result.key, :contributions_count => result.value) }
    results.sort! {|a,b| a.contributions_count <=> b.contributions_count}.reverse!
  end

  def initialize(attributes = {})
    @errors = ActiveModel::Errors.new(self)
    attributes.each do |key, value|
      next unless @@keys.include?(key.to_sym)
      send("#{key}=", value)
    end
    self.contributions_count ||= 0
  end

  def contributions_by_type
    results = Couch.client.design_docs["author"].contributions_by_type(:group => true, :reduce => true, :startkey => ["EmausBot",""], :endkey => ["EmausBot","XXXX"]).entries
  end

end