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
    video_view_count + image_view_count + text_view_count rescue "-"
  end

  # private

  # get view count totals from the periodic counter in the 'views' bucket
  # and from the global counter in the global bucket and combine
  def get_view_counts
    period  = PeriodViewStats.views_by_type(:stale => false)
    global  = GlobalViewStats.views_by_type(:stale => false)
    overall = {}

    overall[:text]    = (global[:text]  || 0) + (period[:text]  || 0)
    overall[:image]   = (global[:image] || 0) + (period[:image] || 0)
    overall[:video]   = (global[:video] || 0) + (period[:video] || 0)
    overall[:overall] = overall[:text]  + overall[:image] + overall[:video]

    overall
  end

end
