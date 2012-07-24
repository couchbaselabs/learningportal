class Content

  BATCH_SIZE    = 10
  BATCH_NUMBER  = 100

  WIKIPEDIA_URL = "http://en.wikipedia.org/w/api.php"

  def self.seed!
    # 1. iterate through batches of random articles up to number
    # 2. cache ID so no duplicate requests
    # 3. schedule delayed job for download of each article
    (1..BATCH_NUMBER).each do |batch|
      job = case rand(2)
      when 0
        TextContentDownloadJob.new
      when 1
        ImageContentDownloadJob.new
      when 2
        VideoContentDownloadJob.new
      end

      Delayed::Job.enqueue job
    end
  end

end