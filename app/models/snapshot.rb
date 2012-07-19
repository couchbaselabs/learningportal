class Snapshot < ActiveRecord::Base

  default_scope :order => 'created_at DESC'

  #before_validation :assign_totals

  def perform!
    assign_totals
    save
  end

  def assign_totals
    views  = GlobalViewStats.views_by_type({}, true)
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

end
