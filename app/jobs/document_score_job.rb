class DocumentScoreJob

  def initialize(document_id)
    @document_id = document_id
  end

  def perform
    # do quality recalculation.

    # 1. what is the maximum amount of views of a piece of content
    #    => 100
    # 2. what is the amount of views for this document?
    #    => 1
    # 3. quality score is as an integer percentage of the max views (rounded up) between 0..100
    #    => 1

    # Probably want to also pass in max view count when scheduling all of these jobs.

  end

end