class Admin::DashboardsController < AdminController

  def show
    @content_view_totals = PeriodViewStats.views_by_type
    @content_view_totals[:overall] = PeriodViewStats.views_by_type.sum{|t| t.last}

    @snapshots = Snapshot.all

  end

  def simulation
    Delayed::Job.enqueue UserLoadJob.new
    redirect_to admin_dashboard_path, :notice => "100 user interations now queued for processing"
  end

end