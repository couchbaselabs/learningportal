class Admin::DashboardsController < AdminController

  def show
    @content_view_totals = PeriodViewStats.views_by_type
    @content_view_totals[:overall] = PeriodViewStats.views_by_type.sum{|t| t.last}

    @snapshots = Snapshot.all

  end

end