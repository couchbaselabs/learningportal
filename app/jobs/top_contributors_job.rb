class TopContributorsJob

  def initialize(limit=8)
    @limit = limit
  end

  def perform
    @top_contribs = []

    @contributors = Couch.client.design_docs["author"].by_contribution_count({ :descending => true, :group => true }).entries
    @contributors.each do |row|
      @top_contribs << Author.new(:name => row.key, :contributions_count => row.value).to_json
    end

    @top_contribs.sort! {|a,b| a[:contributions_count] <=> b[:contributions_count]}
    @top_contribs.reverse!

    Couch.client.set("top_contributors", @top_contribs.take(@limit))
  end

end