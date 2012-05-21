class Article

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Callbacks
  extend ActiveModel::Naming

  def persisted?
    @id
  end

  attr_accessor :id, :categories, :attrs

  def update_attributes(attributes)
    attributes.each do |name, value|
      next if (name == "new_category" || "delete_category") && !value.present?
      # next unless @@keys.include?(name.to_sym)
      send("#{name}=", value)
    end
    update
  end

  def [](key)
    attrs[key]
  end

  def new_category; nil; end
  def delete_category; nil; end

  def delete_category=(category)
    self.categories.delete(category) if self.categories.include?(category)
  end

  def new_category=(category)
    self.categories << category
  end

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