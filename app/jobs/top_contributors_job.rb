class TopContributorsJob

  def initialize(limit=8)
    @limit = limit
  end

  def perform
    @top_contribs = []

    @contributors = Author.bucket.design_docs["author"].by_contribution_count({ :descending => true, :group => true }).entries
    @contributors.each do |row|
      author = Author.new(:name => row.key, :contributions_count => row.value)
      @top_contribs << author
    end

    @top_contribs.sort! {|a,b| a.contributions_count <=> b.contributions_count}
    @top_contribs.reverse!
    @top_contribs = @top_contribs.take(@limit)
    @top_contribs.map! { |contrib| contrib.to_json }

    Couch.client(:bucket => "system").set("top_contributors", @top_contribs)
  end

end