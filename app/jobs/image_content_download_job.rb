class ImageContentDownloadJob

  IMAGE_URL = "http://upload.wikimedia.org/wikipedia/en"
  BLACKLIST = [
    "Question_book-new.svg", "Disambig_gray.svg", "Yes_check.svg", "Wiki_letter_w.svg", "Ambox_content.png", "Red_pog.svg",
    "Edit-clear.svg", "Commons-logo.svg", "PD-icon.svg", "Ambox_content.png", "P_vip.svg", "Text document with red question mark.svg"
  ]

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
      begin
        id, document = parse(article, avg)
        Couch.client.set(id.to_s, document)
        Event.new(:type => Event::CREATE, :user => nil, :resource => id.to_s).save
      rescue

      end
    end

    true
  end

  def fetch(article_ids)
    ids = article_ids.join('|')
    response = Typhoeus::Request.get(Content::WIKIPEDIA_URL,
      :headers => {"User-Agent" => "ES-CB-WikiDownloader"},
      :params => {
        :action  => "query",
        :prop    => "revisions|categories|info|images",
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

    images = json["images"].reject {|image| BLACKLIST.include? "#{image["title"].gsub /^File:/, ""}" }
    image  = image_url(images.first["title"])

    raise if Typhoeus::Request.get(image).code == 404

    document = {
      :title        => json['title'],
      :url          => json['fullurl'],
      :type         => "image",
      :is_text      => 0,
      :is_video     => 0,
      :is_image     => 1,
      :popularity   => popularity,
      :views        => 0,
      :categories   => categories,
      :timestamp    => revision['timestamp'],
      :content      => image,
      :authors      => authors,
      :contributors => contributors
    }

    puts image

    return id, document
  end

  def image_url(title="")
    filename = title.gsub(/^File:/, "").gsub(/ /, "_")

    raise if BLACKLIST.include? filename

    md5 = Digest::MD5.hexdigest(filename)
    "#{IMAGE_URL}/#{md5[0]}/#{md5[0..1]}/#{filename}"
  end

end