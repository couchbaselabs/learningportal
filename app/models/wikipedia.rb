class Wikipedia

  BASE_URL = "http://en.wikipedia.org/w/api.php"
  BATCH    = 10

  # return an array of random wikipedia article references
  def self.random_article_ids
    response = Typhoeus::Request.get(
      "#{BASE_URL}?action=query&list=random&rnnamespace=0&rnlimit=#{BATCH}&rvprop=content&format=json",
      :headers => {"User-Agent" => "ES-CB-WikiDownloader"}
    )
    JSON.parse(response.body)["query"]["random"].map {|article| article["id"]}
  end

  def self.get(id)
    
  end

  def self.seed!(number)
    # 1. iterate through batches of random articles up to number
    # 2. cache ID so no duplicate requests
    # 3. schedule delayed job for download of each article
  end

end