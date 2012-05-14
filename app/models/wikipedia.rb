class Wikipedia

  BASE_URL = "http://en.wikipedia.org/w/api.php"
  BATCH    = 10

  # return an array of random wikipedia article references
  def self.random
    response = Typhoeus::Request.get(BASE_URL,
      :headers => {"User-Agent" => "ES-CB-WikiDownloader"},
      :params => {
        :action      => "query",
        :list        => "random",
        :rnnamespace => 0,
        :rnlimit     => BATCH,
        :rvprop      => "content",
        :format      => "json"
      }
    )
    JSON.parse(response.body)["query"]["random"].map {|article| article["id"]}
  end

  def self.fetch(article_ids)
    ids = article_ids.join('|')
    response = Typhoeus::Request.get(BASE_URL,
      :headers => {"User-Agent" => "ES-CB-WikiDownloader"},
      :params => {
        :action  => "query",
        :prop    => "revisions|categories|info",
        :pageids => ids,
        :rvprop  => "timestamp|user|content|tags",
        :format  => "json",
        :inprop  => "url",
        :cllimit => 500
      }
    )
    JSON.parse(response.body)["query"]["pages"].map {|key, value| value }
  end

  def self.seed!(number)
    # 1. iterate through batches of random articles up to number
    # 2. cache ID so no duplicate requests
    # 3. schedule delayed job for download of each article
  end

end