class Snapshot < ActiveRecord::Base

  before_validation :assign_totals

  def assign_totals
    views = Article.view_stats_type
    totals = Article.totals

    self.text_count = totals[:text]
    self.text_view_count = views[:text]
    self.image_count = totals[:image]
    self.image_view_count = views[:image]
    self.video_count = totals[:video]
    self.video_view_count = views[:video]
  end

  def total_view_count
    video_view_count + image_view_count + text_view_count
  end

end
