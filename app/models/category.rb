class Category < Couchbase::Model

  attr_accessor :name, :count
  @@keys = [:name, :count]
  view :by_popularity, :by_first_letter

  def self.popular(limit=10)
    begin
      tags = Couch.client(:bucket => 'system').get("top_tags")
      return tags.map! { |tag| new (tag) }
    rescue Couchbase::Error::NotFound
      Delayed::Job.enqueue(TopTagsJob.new(limit))
      return []
    end
  end

  def self.by_first_letter(letter="")
    letter = letter.downcase
    results = Couch.client.design_docs["category"].by_first_letter(:group => true, :startkey => [letter, ""], :endkey => [letter, "\u9999"]).entries
    results.map { |result| new(:name => result.key[1]) }
  end

  def initialize(attributes = {})
    @errors = ActiveModel::Errors.new(self)
    attributes.each do |key, value|
      next unless @@keys.include?(key.to_sym)
      send("#{key}=", value)
    end
    self.count ||= 0
  end

  def to_json
    {
      name: name,
      count: count
    }
  end

end