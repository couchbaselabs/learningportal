class Article < Couchbase::Model

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Callbacks
  extend ActiveModel::Naming

  def persisted?
    @id
  end

  attr_accessor :id, :title, :type, :url, :author, :content, :categories, :attrs
  @@keys = [:id, :title, :type, :url, :author, :content, :categories, :attrs]

  def update_attributes(attributes)
    attributes.each do |name, value|
      next if (name == "new_category" || name == "delete_category") && !value.present?
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
    @errors = ActiveModel::Errors.new(self)

    attributes.each do |name, value|
      next unless @@keys.include?(name.to_sym)
      send("#{name}=", value)
    end

    self.attrs = attributes.with_indifferent_access || {}
    self.categories = self.attrs[:categories] || []
  end

  def update
    @attrs.merge!(:categories => @categories, :title => @title)
    Couch.client.set(@id, @attrs)
  end

  def destroy
    Couch.client.delete(@id)
  end

  def count_as_viewed
    Couch.client.incr("view_count_#{id}", 1, :initial => 1)
  end

end