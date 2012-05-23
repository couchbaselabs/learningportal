class Category < Couchbase::Model

  attr_accessor :name, :count
  @@keys = [:name, :count]
  view :by_popularity, :by_first_letter

  def self.popular
    results = Couch.client.design_docs["category"].by_popularity(:descending => true, :group => true).entries
    results.map! { |result| new(:name => result.key, :count => result.value) }
    results.sort! {|a,b| a.count <=> b.count}.reverse!
  end

  def initialize(attributes = {})
    @errors = ActiveModel::Errors.new(self)
    attributes.each do |key, value|
      next unless @@keys.include?(key.to_sym)
      send("#{key}=", value)
    end
    self.count ||= 0
  end

end