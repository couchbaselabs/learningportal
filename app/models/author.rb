class Author < Couchbase::Model

  attr_accessor :name, :contributions_count
  @@keys = [:name, :contributions_count]
  view :by_contribution_count

  def self.popular
    results = by_contribution_count(:descending => true, :group => true).entries
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

end