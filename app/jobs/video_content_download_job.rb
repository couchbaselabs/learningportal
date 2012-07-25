class VideoContentDownloadJob

  STOP_WORDS = JSON.parse(File.read("#{Rails.root}/config/stop_words.json"))

  def initialize
    response = Typhoeus::Request.get(Content::WIKIPEDIA_URL,
      :headers => {"User-Agent" => "ES-CB-WikiDownloader"},
      :params => {
        :action      => "query",
        :list        => "random",
        :rnnamespace => 0,
        :rnlimit     => Content::BATCH_SIZE,
        :rvprop      => "content",
        :format      => "json"
      }
    )
    @article_ids = JSON.parse(response.body)["query"]["random"].map {|article| article["id"]}
  end

  def perform
    articles = fetch(@article_ids)
    avg = 0
    begin
      stats = Article.view_stats
      avg = stats[:avg]
    rescue Couchbase::Error::NotFound

    end

    articles.each do |article|
      id, document = parse(article, avg)
      Couch.client.set(id.to_s, document)
      Event.new(:type => Event::CREATE, :user => nil, :resource => id.to_s).save
    end

    true
  end

  def fetch(article_ids)
    ids = article_ids.join('|')
    response = Typhoeus::Request.get(Content::WIKIPEDIA_URL,
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

  def parse(json, popularity=nil)
    id = json["pageid"]
    categories = json["categories"].map {|c| c['title'].split(':').last }

    popularity = rand(100) + 1 unless popularity

    revision = json["revisions"].first

    contributors = []
    authors = []
    json["revisions"].each do |r|
      authors << {:name => r["user"]}
      contributors << {:name => r["user"], :timestamp => r["timestamp"]}
    end

    authors.uniq!

    keywords = json["title"]
                .downcase
                .gsub(/[^a-z ]/, '')
                .split(" ")
                .reject { |word| (STOP_WORDS.include?(word) || word.size < 4) }

    video = false
    keywords.each do |keyword|
      begin
        video = search_video(keyword)
        break if video
      rescue

      end
    end

    raise unless video

    document = {
      :title        => json['title'],
      :url          => json['fullurl'],
      :type         => "video",
      :is_text      => 0,
      :is_video     => 1,
      :is_image     => 0,
      :popularity   => popularity,
      :views        => 0,
      :categories   => categories,
      :timestamp    => revision['timestamp'],
      :content      => video,
      :authors      => authors,
      :contributors => contributors
    }

    return id, document
  end

  def search_video(keyword="")
    # hit the video endpoint one time to know how many videos are availalbe
    video_search_endpoint  = "http://archive.org/advancedsearch.php?q=#{keyword}+AND+mediatype:movies+AND+licenseurl:[http://creativecommons.org/a+TO+http://creativecommons.org/z]&rows=1&output=json"
    video_details_endpoint = "http://archive.org/details/"

    response = Typhoeus::Request.get(video_search_endpoint)
    response = JSON.parse(response.body)["response"]

    # hit the video endpoint again this time choosing a random video
    num_found = response["numFound"]
    response  = Typhoeus::Request.get(video_search_endpoint + "&page=#{rand(num_found)}")
    video_identifier = JSON.parse(response.body)["response"]["docs"].first["identifier"]

    # yet a further request this time to get the video meta-data itself
    response = Typhoeus::Request.get("#{video_details_endpoint}/#{video_identifier}", :params => { :output => "json" })
    response = JSON.parse(response.body)

    # now pull out the relevant bits to generate the full url to a video
    server   = response["server"]
    path     = response["dir"]
    filename = response["files"].select { |key, file| file["format"] == "Ogg Video" }.first.first

    "http://#{server}#{path}#{filename}"
  end

end