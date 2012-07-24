class VideoContentDownloadJob

  def perform
    #
  end

  def video_url
    # hit the video endpoint one time to know how many videos are availalbe
    video_search_endpoint  = "http://archive.org/advancedsearch.php?q=mediatype:movies+AND+licenseurl:[http://creativecommons.org/a+TO+http://creativecommons.org/z]&rows=1&output=json"
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