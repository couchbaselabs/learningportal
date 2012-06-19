class TopTagsJob

  LIMIT = 8

  def initialize(limit=LIMIT)
    @limit = limit
  end

  def perform
    @top_tags = []

    @categories = Category.bucket.design_docs["category"].by_popularity({ :descending => true, :group => true }).entries
    @categories.each do |row|
      @top_tags << Category.new(:name => row.key, :count => row.value).to_json
    end

    @top_tags.sort! {|a,b| a[:count] <=> b[:count] }
    @top_tags.reverse!

    Couch.client(:bucket => "system").set("tags", {:tags => @top_tags.take(@limit)})
  end

end