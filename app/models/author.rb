class Author < Couchbase::Model

  attr_accessor :name, :contributions_count
  @@keys = [:name, :contributions_count]
  view :by_contribution_count, :contributions_by_type, :by_first_letter

  def self.popular
    results = Couch.client.design_docs["author"].by_contribution_count(:descending => true, :group => true).entries
    results.map! { |result| new(:name => result.key, :contributions_count => result.value) }
    results.sort! {|a,b| a.contributions_count <=> b.contributions_count}.reverse!
  end

  def self.by_first_letter(letter="")
    letter.downcase!
    results = Couch.client.design_docs["author"].by_first_letter(:group => true, :startkey => [letter, ""], :endkey => [letter, "\u9999"]).entries
    results.map { |result| new(:name => result.key[1]) }
  end

  def contributions_by_type
    return @contribs if @contribs.present?
    @contribs = { :overall => 0, :audio => 0, :video => 0, :text => 0 }
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

end