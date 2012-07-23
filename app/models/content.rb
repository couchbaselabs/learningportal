class Content

  CONTENT_TYPES = ["text", "video", "image"]
  WIKIPEDIA_URL = "http://en.wikipedia.org/w/api.php"
  BATCH_SIZE    = 10
  BATCH_NUMBER  = 100

  # return an array of random wikipedia article references
  def self.random
    response = Typhoeus::Request.get(WIKIPEDIA_URL,
      :headers => {"User-Agent" => "ES-CB-WikiDownloader"},
      :params => {
        :action      => "query",
        :list        => "random",
        :rnnamespace => 0,
        :rnlimit     => BATCH_SIZE,
        :rvprop      => "content",
        :format      => "json"
      }
    )
    JSON.parse(response.body)["query"]["random"].map {|article| article["id"]}
  end

  def self.fetch(article_ids)
    ids = article_ids.join('|')
    response = Typhoeus::Request.get(WIKIPEDIA_URL,
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

  def self.image_url
    response = Typhoeus::Request.get(WIKIPEDIA_URL,
      :headers => {"User-Agent" => "ES-CB-WikiDownloader"},
      :params => {
        :action       => "query",
        :generator    => "random",
        :grnnamespace => 6,
        :rnlimit      => 1,
        :prop         => "imageinfo",
        :iiprop       => "url",
        :iiurlwidth   => 640,
        :iiurlheight  => 400,
        :format       => "json"
      }
    )
    JSON.parse(response.body)["query"]["pages"].first[1]["imageinfo"].first["thumburl"]
  end

  def self.video_url
    ""
  end

  def self.seed!
    # 1. iterate through batches of random articles up to number
    # 2. cache ID so no duplicate requests
    # 3. schedule delayed job for download of each article
    (1..BATCH_NUMBER).each do |batch|
      article_ids = self.random
      puts "Batch #{batch}: #{article_ids}"
      Delayed::Job.enqueue( ContentDownloadJob.new( article_ids ) )
    end

    # Delayed::Job.enqueue(TopTagsJob.new(TopTagsJob::TAGS_LIMIT))
    # Delayed::Job.enqueue(TopContributorsJob.new(TopContributorsJob::CONTRIBUTORS_LIMIT))
  end


  def self.parse(json, popularity=nil)
    id = json["pageid"]
    categories = json["categories"].map {|c| c['title'].split(':').last }

    random_type = rand(3)
    popularity = rand(100) + 1 unless popularity

    revision = json["revisions"].first

    contributors = []
    authors = []
    json["revisions"].each do |r|
      authors << {:name => r["user"]}
      contributors << {:name => r["user"], :timestamp => r["timestamp"]}
    end

    authors.uniq!

    content = case random_type
    when 0
      revision["*"]
    when 1
      # self.video_url
      revision["*"]
    when 2
      self.image_url
    end

    document = {
      :title => json['title'],
      :url => json['fullurl'],
      :type => CONTENT_TYPES[random_type],
      :is_text => (random_type == 0),
      :is_video => (random_type == 1),
      :is_image => (random_type == 2),
      :popularity => popularity,
      :views => 0,
      :categories => categories,
      :timestamp => revision['timestamp'],
      :content => content,
      :authors => authors,
      :contributors => contributors
    }
    return id, document
  end

end