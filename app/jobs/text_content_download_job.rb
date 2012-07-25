class TextContentDownloadJob

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

    document = {
      :title        => json['title'],
      :url          => json['fullurl'],
      :type         => "text",
      :is_text      => 1,
      :is_video     => 0,
      :is_image     => 0,
      :popularity   => popularity,
      :views        => 0,
      :categories   => categories,
      :timestamp    => revision['timestamp'],
      :content      => revision["*"],
      :authors      => authors,
      :contributors => contributors
    }

    return id, document
  end

end