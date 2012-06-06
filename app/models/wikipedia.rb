class Wikipedia

  ARTICLE_TYPES = ["text", "video", "image"]
  BASE_URL      = "http://en.wikipedia.org/w/api.php"
  BATCH         = 10
  BATCHES       = 10

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

  def self.seed!
    # 1. iterate through batches of random articles up to number
    # 2. cache ID so no duplicate requests
    # 3. schedule delayed job for download of each article
    (1..BATCHES).each do |batch|
      article_ids = self.random
      puts "Batch #{batch}: #{article_ids}"
      Delayed::Job.enqueue( WikipediaDownloadJob.new( article_ids ) )
    end
  end


  def self.parse(json)
    id = json["pageid"]
    categories = json["categories"].map {|c| c['title'].split(':').last }

    random_type = rand(3)
    random_quality = rand(100) + 1;

    revision = json["revisions"].first

    contributors = []
    authors = []
    json["revisions"].each do |r|
      authors << {:name => r["user"]}
      contributors << {:name => r["user"], :timestamp => r["timestamp"]}
    end

    authors.uniq!

    document = {
      :title => json['title'],
      :url => json['fullurl'],
      :type => ARTICLE_TYPES[random_type],
      :is_text => (random_type == 0),
      :is_video => (random_type == 1),
      :is_image => (random_type == 2),
      :quality => random_quality,
      :categories => categories,
      :timestamp => revision['timestamp'],
      :content => revision['*'],
      :authors => authors,
      :contributors => contributors
    }
    return id, document
  end

end