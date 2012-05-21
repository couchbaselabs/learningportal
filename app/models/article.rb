class Article

  attr_accessor :id, :categories, :attrs

  def self.find(id)
    id = id.to_s if id.kind_of?(Fixnum)
    new( Couch.client.get(id).merge("id" => id) )
  end

  def initialize(attributes={})
    @attrs = attributes.with_indifferent_access || {}
    @id  = @attrs["id"].to_s
    @categories = @attrs[:categories] || []
  end

  def update
    @attrs.merge!(:categories => @categories)
    Couch.client.set(@id, @attrs)
  end

end