class Author

  include ActiveModel::Validations

  attr_accessor :name, :contributions_count
  @@keys = [:name, :contributions_count]
  @@doc = 'author'
  @@design_doc = {
    '_id' => "_design/#{@@doc}",
    'views' => {
      'by_contribution_count' => {
        'map' => 'function(doc){ doc.authors.forEach(function(author){ emit(author.name, null); }) }',
        'reduce' => '_count'
      }
    }
  }

  def self.design
    @@design ||= Couch.client.design_docs[@@doc]
  end

  def self.couch
    Couch.client
  end

  def self.update_design_doc!
    if couch.design_docs.include?(@@doc)
      couch.delete_design_doc(@@doc)
      couch.save_design_doc(@@design_doc.to_json)
    else
      couch.save_design_doc(@@design_doc.to_json)
    end
  end

  def self.popular
    results = Author.design.by_contribution_count(:descending => true, :group => true).entries
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