class Category

  include ActiveModel::Validations

  attr_accessor :name, :count
  @@keys = [:name, :count]
  @@doc = 'category'
  @@design_doc = {
    '_id' => "_design/#{@@doc}",
    'views' => {
      'by_popularity' => {
        'map' => 'function(doc){ doc.categories.forEach(function(category){ emit(category, null); }) }',
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
    results = Category.design.by_popularity(:descending => true, :group => true).entries
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