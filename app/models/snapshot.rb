class Snapshot < ActiveRecord::Base

  #before_validation :assign_totals

  def perform!
    assign_totals
    save
  end

  def assign_totals
    views  = get_view_counts
    totals = Article.totals

    self.text_count       = totals[:text]  || 0
    self.text_view_count  = views[:text]   || 0
    self.image_count      = totals[:image] || 0
    self.image_view_count = views[:image]  || 0
    self.video_count      = totals[:video] || 0
    self.video_view_count = views[:video]  || 0
  end

  def total_view_count
    video_view_count + image_view_count + text_view_count rescue ""
  end

  # private

  # get view count totals from the counter docs in the 'views' bucket
  # and from the content itself in the default bucket and combine
  def get_view_counts
    counters = ViewStats.views_by_type(:stale => false)
    docs     = Article.views_by_type(:stale => false)
    overall  = {}

    overall[:text]  = docs[:text]  + counters[:text]
    overall[:image] = docs[:image] + counters[:image]
    overall[:video] = docs[:video] + counters[:video]
    overall[:overall] = overall[:text] + overall[:image] + overall[:video]

    overall
  end

end
